#import "Math";

#scope_file
Camera :: struct {
  pos : Vector3 = .{0, 0, 5};
  rotation : Quaternion;
  fov : float = 70;
  z_near : float = 0.1;
  z_far : float = 1024.0;
  transformation : Matrix4 = Matrix4_Identity;
  projection : Matrix4 = Matrix4_Identity;
}
primary_camera : Camera;


#scope_export

matrix4_identity :: (matrix : *Matrix4) {
  matrix._11 = 1.0;
  matrix._12 = 0.0;
  matrix._13 = 0.0;
  matrix._14 = 0.0;
  matrix._21 = 0.0;
  matrix._22 = 1.0;
  matrix._23 = 0.0;
  matrix._24 = 0.0;
  matrix._31 = 0.0;
  matrix._32 = 0.0;
  matrix._33 = 1.0;
  matrix._34 = 0.0;
  matrix._41 = 0.0;
  matrix._42 = 0.0;
  matrix._43 = 0.0;
  matrix._44 = 1.0;
}

update_camera_transformation :: () {
  matrix4_identity(*primary_camera.transformation); // Reset the transformation to the identity.
  // Augment the transform by rotation and translation.
  primary_camera.transformation = rotate(primary_camera.transformation, primary_camera.rotation);
  translate(*primary_camera.transformation, primary_camera.pos);
}

update_camera_projection :: () {
  primary_camera.projection = make_projection_matrix(primary_camera.fov, xx window_properties.aspect_ratio, primary_camera.z_near, primary_camera.z_far);
}

get_camera_projection :: () -> Matrix4 {
  return primary_camera.projection;
}

get_camera_transformation :: () -> Matrix4 {
  return inverse(primary_camera.transformation);
}

translate_camera :: (x : float, y : float, z : float) {
  primary_camera.pos.x += x;
  primary_camera.pos.y += y;
  primary_camera.pos.z -= z;
}

set_camera_pos :: (x : float, y : float, z : float) {
  primary_camera.pos.x =  x;
  primary_camera.pos.y =  y;
  primary_camera.pos.z = -z;
}
