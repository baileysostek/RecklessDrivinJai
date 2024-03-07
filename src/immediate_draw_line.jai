#scope_file
immediate_shader_program : GLuint; 

DEFAULT_LINE_THICKNESS : float : 1.0;
line_thickness := DEFAULT_LINE_THICKNESS;

initialized : bool = false;

// Specify the maximum number of lines we can draw on the screen.
MAX_LINES : u32 : 2048;

// Properties to send to our shader.
positions : [MAX_LINES * 3 * 2] float; // 3 floats per vertex 2 vertices per line
colors : [MAX_LINES * 4 * 2] float;// 4 floats per vertex 2 colors per line
// How many lines we have attempted to draw this frame.
draw_index : u32 = 0;

// We need a VAO and two VBOS
immediate_line_vao_id : u32;
immediate_line_vbo_pos : u32;
immediate_line_vbo_col : u32;

#scope_export
ImmediateDrawLine :: struct {

  initialize :: () {
    if initialized return; // Only run once.
    initialized = true;

    // Iniitalize all of the properties we need to initialize.
    immediate_shader_program = compile_shader("immediate_color");

    // Gen our VAO
    glGenVertexArrays(1, *immediate_line_vao_id);  
    glBindVertexArray(immediate_line_vao_id);
    // Gen Buffers
    glGenBuffers(1, *immediate_line_vbo_pos);
    glBindBuffer (GL_ARRAY_BUFFER, immediate_line_vbo_pos);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, cast(*void) 0);
    glGenBuffers(1, *immediate_line_vbo_col);
    glBindBuffer (GL_ARRAY_BUFFER, immediate_line_vbo_col);
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, 0, cast(*void) 0);

    // Unbind
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
  }

  set_line_thickness :: (thickness : float) {
    line_thickness = thickness;
  }

  // Externally callable functions to use this Immediate draw code.
  draw_line :: (from_x : float, from_y : float, from_z : float, to_x : float, to_y : float, to_z : float, color_src_r : float, color_src_g : float, color_src_b : float, color_src_a : float, color_dst_r : float, color_dst_g : float, color_dst_b : float, color_dst_a : float) {
    if draw_index >= MAX_LINES return; // Out of lines to draw this frame.
    // Populate our float arrays. Start with positions
    positions[draw_index * 6 + 0] = from_x;
    positions[draw_index * 6 + 1] = from_y;
    positions[draw_index * 6 + 2] = from_z;
    positions[draw_index * 6 + 3] = to_x;
    positions[draw_index * 6 + 4] = to_y;
    positions[draw_index * 6 + 5] = to_z;
    // Set the colors of this line.
    colors[draw_index * 8 + 0] = color_src_r;
    colors[draw_index * 8 + 1] = color_src_g;
    colors[draw_index * 8 + 2] = color_src_b;
    colors[draw_index * 8 + 3] = color_src_a;
    colors[draw_index * 8 + 4] = color_dst_r;
    colors[draw_index * 8 + 5] = color_dst_g;
    colors[draw_index * 8 + 6] = color_dst_b;
    colors[draw_index * 8 + 7] = color_dst_a;
    // Increment the draw index.
    draw_index += 1;
  }

  draw_line :: (from : Vector3, to : Vector3, src_color : Vector4 = .{1.0, 1.0, 1.0, 1.0}, dst_color : Vector4 = .{1.0, 1.0, 1.0, 1.0}) {
    draw_line(from.x, from.y, from.z, to.x, to.y, to.z, src_color.x, src_color.y, src_color.z, src_color.w, dst_color.x, dst_color.y, dst_color.z, dst_color.w);
  }

  draw_orientation :: (position : Vector3, rotation : Quaternion) {

  }

  draw_cube :: (pos : Vector3, scale : Vector3 = .{1, 1, 1}, color : Vector4 = .{1, 1, 1, 1}) {
    half_scale_x : float = scale.x / 2.0;
    half_scale_y : float = scale.y / 2.0;
    half_scale_z : float = scale.z / 2.0;
    
    // Bottom Face
    draw_line(pos.x - half_scale_x, pos.y - half_scale_y, pos.z - half_scale_z, pos.x + half_scale_x, pos.y - half_scale_y, pos.z - half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    draw_line(pos.x + half_scale_x, pos.y - half_scale_y, pos.z - half_scale_z, pos.x + half_scale_x, pos.y - half_scale_y, pos.z + half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    draw_line(pos.x + half_scale_x, pos.y - half_scale_y, pos.z + half_scale_z, pos.x - half_scale_x, pos.y - half_scale_y, pos.z + half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    draw_line(pos.x - half_scale_x, pos.y - half_scale_y, pos.z + half_scale_z, pos.x - half_scale_x, pos.y - half_scale_y, pos.z - half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    // Top Face
    draw_line(pos.x - half_scale_x, pos.y + half_scale_y, pos.z - half_scale_z, pos.x + half_scale_x, pos.y + half_scale_y, pos.z - half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    draw_line(pos.x + half_scale_x, pos.y + half_scale_y, pos.z - half_scale_z, pos.x + half_scale_x, pos.y + half_scale_y, pos.z + half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    draw_line(pos.x + half_scale_x, pos.y + half_scale_y, pos.z + half_scale_z, pos.x - half_scale_x, pos.y + half_scale_y, pos.z + half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    draw_line(pos.x - half_scale_x, pos.y + half_scale_y, pos.z + half_scale_z, pos.x - half_scale_x, pos.y + half_scale_y, pos.z - half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    // Connect Bottom face to top face
    draw_line(pos.x - half_scale_x, pos.y - half_scale_y, pos.z - half_scale_z, pos.x - half_scale_x, pos.y + half_scale_y, pos.z - half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    draw_line(pos.x + half_scale_x, pos.y - half_scale_y, pos.z - half_scale_z, pos.x + half_scale_x, pos.y + half_scale_y, pos.z - half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    draw_line(pos.x + half_scale_x, pos.y - half_scale_y, pos.z + half_scale_z, pos.x + half_scale_x, pos.y + half_scale_y, pos.z + half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
    draw_line(pos.x - half_scale_x, pos.y - half_scale_y, pos.z + half_scale_z, pos.x - half_scale_x, pos.y + half_scale_y, pos.z + half_scale_z, color.x, color.y, color.z, color.w, color.x, color.y, color.z, color.w);
  }

  render :: () {
    // Enable 
    glEnable(GL_LINE_SMOOTH);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // Set the line thickness
    glLineWidth(line_thickness);

    // VertexData
    glUseProgram(immediate_shader_program);

    // Load our uniform variables.
    upload_uniform_data("transformation", get_camera_transformation(), immediate_shader_program);
    upload_uniform_data("projection", get_camera_projection(), immediate_shader_program);

    // Load our arrays into our VBOs
    glBindVertexArray(immediate_line_vao_id);
    glBindBuffer(GL_ARRAY_BUFFER, immediate_line_vbo_pos);
    glBufferData(GL_ARRAY_BUFFER, size_of(float) * positions.count, positions.data, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, immediate_line_vbo_col);
    glBufferData(GL_ARRAY_BUFFER, size_of(float) * colors.count, colors.data, GL_STATIC_DRAW);
    // Enable Vertex Attribute arrays
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);

    // Render all of our lines
    glDrawArrays(GL_LINES, 0, draw_index * 2);
    // print("Rendering [%]Lines\n", draw_index);

    // Disable our Vertex Attribute arrays
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);

    // Reset our shader program and bound VAOs
    glUseProgram(0);

    // Reset our draw index so that next frame we can draw new lines.
    draw_index = 0;

    // Reset properties
    glDisable(GL_LINE_SMOOTH);
    glDisable(GL_BLEND);
    glLineWidth(DEFAULT_LINE_THICKNESS); // Reset line width.
  }
}