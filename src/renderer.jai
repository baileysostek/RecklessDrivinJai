vertices := Vector3.[.{-0.5, -0.5, 0.0}, .{0.5, -0.5, 0.0}, .{-0.5, 0.5, 0.0}, .{-0.5, 0.5, 0.0}, .{0.5, -0.5, 0.0}, .{0.5, 0.5, 0.0}];

vbo : u32;
vao : u32;

shader_program_id : GLuint;

// Load subsequent things
#load "shader_manager.jai";

// Load our immeidate renderers
#load "immediate_draw_line.jai";

render_init :: () {
  // Compile shader program.
  shader_program_id = compile_shader("hello_triangle");
  // Gen our VAO
  glGenVertexArrays(1, *vao);  
  glBindVertexArray(vao);
  // Gen Buffers
  glGenBuffers(1, *vbo);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, size_of(Vector3) * vertices.count, vertices.data, GL_STATIC_DRAW);
  // Bind the attributes and enable them
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * size_of(float), xx 0);
  glEnableVertexAttribArray(0);

  glEnable(GL_DEPTH_TEST);

  // Initialize our DirectDraw3D code
  ImmediateDrawLine.initialize();

  // glEnable(GL_CULL_FACE);
  // glCullFace(GL_BACK);
}

render :: () {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  // glClearColor(.56, .2, .8, 1);

  // Upload uniforms
  // Use the program
  glUseProgram(shader_program_id);
  upload_uniform_data("transformation", get_camera_transformation(), shader_program_id);
  upload_uniform_data("projection", get_camera_projection(), shader_program_id);
  upload_uniform_data("model", model_matrix, shader_program_id);

  glBindVertexArray(vao);
  glDrawArrays(GL_TRIANGLES, 0, vertices.count);
  glBindVertexArray(0);

  // At this point the renderer is done with shader_program_id
  ImmediateDrawLine.render();
  

}