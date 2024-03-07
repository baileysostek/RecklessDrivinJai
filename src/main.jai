// Imports
#import "Math";
#import "Basic";
#import "String";
#import "SDL";
#import "GL";

// Load any Game specific code.
#load "window.jai";
#load "camera.jai";
#load "renderer.jai";

main :: () {
  // Init SDL
  SDL_Init(SDL_INIT_VIDEO);

  // Determine what platform we are on.
  platform := to_string(SDL_GetPlatform());
  print ("Platform = %\n", platform);

  // Set the window title.
  window_properties.name = tprint("Reckless Drivin' [%]", platform);

  // Before creating the window we can set the desired fullscreens state
  // set_fullscreen_state(true);
  // Create a window
  create_window();

  // We have created our window, so now we can run the initializer.
  initialize();

  initialize_shader_manager();
  render_init();

  running = true;
  last_time = seconds_since_init();

  on_resize(window_properties.width, window_properties.height, window_properties.aspect_ratio);

  while running {
    // This is a new frame, so increment our FPS counter.
    fps += 1;

    // Process SDL events
    event : SDL_Event;
    while SDL_PollEvent(*event) {
      on_event(event);
    }

    // Compute our Delta Time.
    now := seconds_since_init();
    delta_time = now - last_time;
    last_time = now;
    running_delta += delta_time;
    if(running_delta > 1.0){
      running_delta -= 1.0;
      print("FPS:%\n", fps);
      fps = 0;
    }

    // Update
    update(delta_time);
    // Render
    render();
    // post-render
    SDL_GL_SwapWindow(window_properties.window);
  }


  SDL_DestroyWindow(window_properties.window);
  SDL_Quit();
}

initialize :: () { // @Drivin:Init
  // Here Reckless Drivin' checks to see if the game is registered or not.
  // We do not care about registration as this will be a share-ware version of the game; True to the original form of the game.
  
}

update :: (delta_time : float64) { // @Drivin:GameFrame
  // Update the camera
  update_camera_transformation();

  angle += (xx delta_time);
  set_from_axis_and_angle(*model_rotation, 0, 1, 0, angle);
  matrix4_identity(*model_matrix);
  model_matrix = rotate(model_matrix, model_rotation);  

  // Keys for window manipulation
  if keys[SDL_SCANCODE_F11] toggle_fullscreen();
  if keys[SDL_SCANCODE_F12] set_vsync(!window_properties.vsync);

  // For now we will control the camera 
  if keys[SDL_SCANCODE_UP] translate_camera(0, 0, 4.0 * (cast(float32)delta_time));
  if keys[SDL_SCANCODE_DOWN] translate_camera(0, 0, -4.0 * (cast(float32)delta_time));
  if keys[SDL_SCANCODE_LEFT] print("Left\n");
  if keys[SDL_SCANCODE_RIGHT] print("Right\n");
  if keys[SDL_SCANCODE_W] translate_camera(0, 4.0 * (cast(float32)delta_time), 0);
  if keys[SDL_SCANCODE_A] translate_camera(-4.0 * (cast(float32)delta_time), 0, 0);
  if keys[SDL_SCANCODE_S] translate_camera(0, -4.0 * (cast(float32)delta_time), 0);
  if keys[SDL_SCANCODE_D] translate_camera(4.0 * (cast(float32)delta_time), 0, 0);

}

on_resize :: (width : s32, height : s32, aspect_ratio : float64) {
  // Update the Camera's projection matrix
  update_camera_projection();
  // Update the GL viewport.
  glViewport(0, 0, xx window_properties.width, xx window_properties.height);
  // Print a message with this resize info.
  print("Window has changed size. New size is %,% Aspect Ratio is:%\n", width, height, aspect_ratio);
  // upload the aspect ratio to the shaders.
  upload_uniform_data("aspect_ratio", cast(float32) aspect_ratio, shader_program_id);
}

keys : [322] bool; // 322 is the max number event.key.keysym.sym can be.
on_event :: (event : SDL_Event) { //@Drivin:Eventloop
  if event.type == {
    case SDL_QUIT;
      running = false;
    case SDL_KEYUP;
      // Get the key that was pressed.
      key := (cast(s32)event.key.keysym.scancode & 0x000000FF);
      keys[key] = false;
    case SDL_KEYDOWN;
      // Get the key that was pressed.
      key := (cast(s32)event.key.keysym.scancode & 0x000000FF);
      keys[key] = true;
      // If we press escape
      if key == xx SDL_SCANCODE_ESCAPE running = false;
    case SDL_WINDOWEVENT;
      if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
        // Update the window properties.
        window_properties.width = xx event.window.data1;
        window_properties.height = xx event.window.data2;
        // Compute aspect ratio of new screen resolution.
        window_properties.aspect_ratio = (cast(float64) window_properties.width) / (cast(float64) window_properties.height);
        // Run the resize callback.
        on_resize(window_properties.width, window_properties.height, window_properties.aspect_ratio);
      }
  }
}


model_matrix : Matrix4 = Matrix4_Identity;
model_rotation : Quaternion = .{0, 0, 0, 1};
angle : float = 0;

#scope_file
running : bool = false;
// Delta time variables.
last_time : float64 = 0;
delta_time : float64 = 0;
running_delta : float64 = 0;
fps : u32 = 0;