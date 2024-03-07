// Imports
#import "Math";
#import "Basic";
#import "String";
#import "SDL";
#import "GL";

Monitor_Properties :: struct {
  // Resolution
  resolution_width : u32 = 0;
  resolution_height : u32 = 0;
  // Monitor Frame Rate
  frame_rate : u32 = 0;
}
monitor_properties : Monitor_Properties;

Window_Properties :: struct {
  // Geometry information position and size
  x : s32 = 0;
  y : s32 = 0;
  width : s32 = 640;
  height : s32 = 480;
  // Aspect Ratio
  aspect_ratio : float64 = #run 640.0 / 480.0;
  // We want to persist the last size the window was in the case of a fullscreen toggle
  last_width : s32 = 640;
  last_height : s32 = 480;
  // Aspects of the window
  name : string = "Test";
  fullscreen : bool = false;
  vsync : bool = true;
  // Window pointer
  window : *SDL_Window;
}
window_properties : Window_Properties;

// Create window
create_window :: () {
  // Get Sizing information about the monitor
  sdl_display_mode : SDL_DisplayMode;
  SDL_GetDesktopDisplayMode(0, *sdl_display_mode);
  monitor_properties.resolution_width = xx sdl_display_mode.w;
  monitor_properties.resolution_height = xx sdl_display_mode.h;
  monitor_properties.frame_rate = xx sdl_display_mode.refresh_rate;

  // Store the window flags, modify them based on the pre-configured window_properties state
  window_flags := SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE;
  if(window_properties.fullscreen){
    // Append the FULLSCREEN flag to the current window flags.
    window_flags = window_flags | SDL_WINDOW_FULLSCREEN;
    // Remember the last window size for when fullscreen is minimized.
    window_properties.last_width = window_properties.width;
    window_properties.last_height = window_properties.height;
    // Set the target size to be the size of the monitor.
    window_properties.width = xx monitor_properties.resolution_width;
    window_properties.height = xx monitor_properties.resolution_height;
  }

  // Create a window.
  window_properties.window = SDL_CreateWindow(to_c_string(window_properties.name), SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, xx window_properties.width, xx window_properties.height, window_flags);
  // Compute aspect ratio of new screen resolution.
  window_properties.aspect_ratio = (cast(float64) window_properties.width) / (cast(float64) window_properties.height);

  // Check that the window was successfully created
  if window_properties.window == null {
    // In the case that the window could not be made...
    print("Could not create window: %\n", to_string(SDL_GetError()));
    return;
  }

  // Set the GL version
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);

  gl_context := SDL_GL_CreateContext(window_properties.window);
  if !gl_context {
    print( "Could not create OpenGL context: %\n", to_string(SDL_GetError()));
    return;
  }  
  gl_load(*gl, SDL_GL_GetProcAddress);
  using gl;

  print ("GL Vendor = %\n", to_string(glGetString(GL_VENDOR)));
  print ("GL Version = %\n", to_string(glGetString(GL_VERSION)));
}

toggle_fullscreen :: () {
  set_fullscreen_state(!window_properties.fullscreen);
}

set_fullscreen_state :: (is_fullscreen : bool) {
  // If there is a change in the fullscreen state.
  if(is_fullscreen != window_properties.fullscreen){
    // Update window properties.
    window_properties.fullscreen = is_fullscreen;
    // Store the target resolution
    target_resolution_width : u32 = xx window_properties.last_width;
    target_resolution_height : u32 = xx window_properties.last_height;
    if window_properties.fullscreen {
      // If this is fullscreen, we want to persist the size of the window.
      window_properties.last_width = window_properties.width;
      window_properties.last_height = window_properties.height;
      // Override the target width and height
      target_resolution_width = monitor_properties.resolution_width;
      target_resolution_height = monitor_properties.resolution_height;
    }
    // // Update the window resolution to the target resolkution.
    // window_properties.width = xx target_resolution_width;
    // window_properties.height = xx target_resolution_height;
    // If we have a window.
    if(window_properties.window){
      // Command the window to be the size of the monitor.
      SDL_SetWindowSize(window_properties.window, xx target_resolution_width, xx target_resolution_height);
      // Use SDL API to command window state.
      SDL_SetWindowFullscreen(window_properties.window, xx ifx window_properties.fullscreen then 1 else 0);
      // If we are exiting fullscreen
      // if !is_fullscreen SDL_SetWindowPosition(window_properties.window, xx ((monitor_properties.resolution_width - xx window_properties.width) / 2.0), xx ((monitor_properties.resolution_height - xx window_properties.height) / 2.0));
    }
  }
}

set_vsync :: (use_vsync : bool) {
  if(window_properties.vsync != use_vsync){
    window_properties.vsync = use_vsync;
    SDL_GL_SetSwapInterval(xx ifx window_properties.vsync then 1 else 0);
  }
}