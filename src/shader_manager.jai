#import "System";  // For get_path_of_running_executable.
#import "File";

#scope_file
// Local Variables
shader_programs : [..] GLuint;
initialized : bool = false;
PATH_TO_RESOURCES :: "res/";
PATH_TO_SHADER_RESOURCES :: "shaders/";
path_to_shaders : string;
VERTEX_SHADER_FILE_NAME :: "shader.vert";
FRAGMENT_SHADER_FILE_NAME :: "shader.frag";
path : string;

ShaderUniform :: struct {
  uniform_name : string;
}

UniformFloat :: struct {
  #as using shader_uniform : ShaderUniform;
}

ShaderProgram :: struct {
  // The name of the shader
  shader_name : string;
  // The Program ID of this shader
  program_id : GLuint;
  // Uniform Variables
  uniforms : [..] *ShaderUniform;
}

ShaderPipeline :: struct {
  shaders : [..] *ShaderProgram;
}

// Local Procedures
create_shader_program :: (vertex_source : string, fragment_source : string) -> GLuint, bool
{
	check_compile_errors :: (shader : GLuint) -> bool, info_log : string
	{
		success : s32;
		glGetShaderiv (shader, GL_COMPILE_STATUS, *success);
		if !success
		{
			info_len : s32;
			glGetShaderiv (shader, GL_INFO_LOG_LENGTH, *info_len);
			info_data := cast (*u8) alloc (info_len,, temp);
			glGetShaderInfoLog (shader, xx info_len, xx *info_len, info_data);
			result : string;
			result.data = info_data;
			result.count = info_len;

			return false, result;
		}

		return true, "";
	}

	check_link_errors :: (program : GLuint) -> bool, info_log : string
	{
		success : s32;
		glGetProgramiv (program, GL_LINK_STATUS, *success);
		if !success
		{
			info_len : s32;
			glGetProgramiv (program, GL_INFO_LOG_LENGTH, *info_len);
			info_data := cast (*u8) alloc (info_len,, temp);
			glGetProgramInfoLog (program, xx info_len, xx *info_len, info_data);
			result : string;
			result.data = info_data;
			result.count = info_len;

			return false, result;
		}

		return true, "";
	}

	// OpenGL requires us to create at least a vertex shader and a
	// fragment shader, to create a shader program that it can execute.
	vs := glCreateShader (GL_VERTEX_SHADER);
	defer glDeleteShader (vs);
	glShaderSource (vs, 1, *vertex_source.data, null);
	glCompileShader (vs);
	ok, info_log := check_compile_errors (vs);
	if !ok
	{
		log_error ("Could not compile vertex shader: %", info_log);
		return 0, false;
	}
	
	fs := glCreateShader (GL_FRAGMENT_SHADER);
	defer glDeleteShader (fs);
	glShaderSource (fs, 1, *fragment_source.data, null);
	glCompileShader (fs);
	ok, info_log = check_compile_errors (fs);
	if !ok
	{
		log_error ("Could not compile fragment shader: %", info_log);
		return 0, false;
	}

	result := glCreateProgram ();
	glAttachShader (result, vs);
	glAttachShader (result, fs);
	glLinkProgram (result);
	ok, info_log = check_link_errors (result);
	if !ok
	{
		log_error ("Could not link shader program: %", info_log);
		glDeleteProgram (result);
		return 0, false;
	}

  array_add(*shader_programs, result);

	return result, true;
}

#scope_export
initialize_shader_manager :: () {
  if initialized return; // If we are already initialized return.
  initialized = true;
  // Load this path information once.
  path := path_strip_filename(get_path_of_running_executable());
  path_to_shaders = join(path, PATH_TO_RESOURCES, PATH_TO_SHADER_RESOURCES);
  print("path_to_shaders is '%'\n", path_to_shaders);
}


compile_shader :: (shader_name : string) -> GLuint, bool {
  // Load our source.
  vertex_source, vertex_success := read_entire_file(join(path_to_shaders, shader_name, "/", VERTEX_SHADER_FILE_NAME));
  fragment_source, fragment_success := read_entire_file(join(path_to_shaders, shader_name, "/", FRAGMENT_SHADER_FILE_NAME));  
  // IF there were no errors, compile our program.
  if(vertex_success && fragment_success){
    program_id, success := create_shader_program(vertex_source, fragment_source);
    print("Compiled Shader[%]\n", shader_name);
    return program_id, success;
  }
  return 0, false;
}

upload_uniform_data :: (uniform_name : string, data : float, shader_program_id : GLuint) {
  // Convert the name to a c_str
  gl_uniform_name := to_c_string(uniform_name);
  defer free(gl_uniform_name);
  // Get the location of this uniform.
  uniform_location := glGetUniformLocation(shader_program_id, gl_uniform_name);
  // If we have a location for this uniform
  if uniform_location >= 0 {
    glUniform1f(uniform_location, data);
  } else {
    // TODO: Alert that the uniform location is empty.
  }
}

upload_uniform_data :: (uniform_name : string, data : Matrix4, shader_program_id : GLuint) {
  // Convert the name to a c_str
  gl_uniform_name := to_c_string(uniform_name);
  defer free(gl_uniform_name);
  // Get the location of this uniform.
  uniform_location := glGetUniformLocation(shader_program_id, gl_uniform_name);
  // If we have a location for this uniform
  if uniform_location >= 0 {
    glUniformMatrix4fv(uniform_location, 1, GL_TRUE, *data.coef[0][0]);
  } else {
    // TODO: Alert that the uniform location is empty.
  }
}