/*
 * Copyright (c) 2013-2014 Kim Pedersen
 * http://47.110.91.75/devindazzle/SCNVector3Extensions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import SceneKit 

extension SCNVector3
{
  /**
   * Negates the vector described by SCNVector3 and returns
   * the result as a new SCNVector3.
   */
  func negate() -> SCNVector3 {
    return self * -1
  }

  /**
   * Negates the vector described by SCNVector3
   */
  mutating func negated() -> SCNVector3 {
    self = negate()
    return self
  }

  /**
   * Returns the length (magnitude) of the vector described by the SCNVector3
   */
  func length() -> Float {
    return sqrtf(x*x + y*y + z*z)
  }

  /**
   * Normalizes the vector described by the SCNVector3 to length 1.0 and returns
   * the result as a new SCNVector3.
   */
  func normalized() -> SCNVector3 {
    return self / length()
  }

  /**
   * Normalizes the vector described by the SCNVector3 to length 1.0.
   */
  mutating func normalize() -> SCNVector3 {
    self = normalized()
    return self
  }

  /**
   * Calculates the distance between two SCNVector3. Pythagoras!
   */
  func distance(_ vector: SCNVector3) -> Float {
    return (self - vector).length()
  }

  func angle(between vector: SCNVector3) -> Float {

    let len = self.length() * vector.length()
    if len == 0 { return 0.0 }

    return acos( min(1.0, max(-1.0, self.dot(vector) / len)) )

  }

}

/**
 * Adds two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
 * Increments a SCNVector3 with the value of another.
 */
func += (left: inout SCNVector3, right: SCNVector3) {
  left = left + right
}

/**
 * Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

/**
 * Decrements a SCNVector3 with the value of another.
 */
func -= (left: inout  SCNVector3, right: SCNVector3) {
  left = left - right
}

/**
 * Multiplies two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
}

/**
 * Multiplies a SCNVector3 with another.
 */
func *= (left: inout  SCNVector3, right: SCNVector3) {
  left = left * right
}

/**
 * Multiplies the x, y and z fields of a SCNVector3 with the same scalar value and
 * returns the result as a new SCNVector3.
 */
func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
  return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

/**
 * Multiplies the x and y fields of a SCNVector3 with the same scalar value.
 */
func *= (vector: inout  SCNVector3, scalar: Float) {
  vector = vector * scalar
}

/**
 * Divides two SCNVector3 vectors abd returns the result as a new SCNVector3
 */
func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
 * Divides a SCNVector3 by another.
 */
func /= (left: inout  SCNVector3, right: SCNVector3) {
  left = left / right
}

/**
 * Divides the x, y and z fields of a SCNVector3 by the same scalar value and
 * returns the result as a new SCNVector3.
 */
func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
  return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}

/**
 * Divides the x, y and z of a SCNVector3 by the same scalar value.
 */
func /= (vector: inout  SCNVector3, scalar: Float) {
  vector = vector / scalar
}

/**
 * Negate a vector
 */
func SCNVector3Negate(vector: SCNVector3) -> SCNVector3 {
  return vector * -1
}

/**
 * Returns the length (magnitude) of the vector described by the SCNVector3
 */
func SCNVector3Length(_ vector: SCNVector3) -> Float
{
  return sqrtf(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z)
}

/**
 * Returns the distance between two SCNVector3 vectors
 */
func SCNVector3Distance(vectorStart: SCNVector3, vectorEnd: SCNVector3) -> Float {
  return SCNVector3Length(vectorEnd - vectorStart)
}

/**
 * Returns the distance between two SCNVector3 vectors
 */
func SCNVector3Normalize(vector: SCNVector3) -> SCNVector3 {
  return vector / SCNVector3Length(vector)
}

/**
 * Calculates the dot product between two SCNVector3 vectors
 */
func SCNVector3DotProduct(_ left: SCNVector3, right: SCNVector3) -> Float {
  return left.x * right.x + left.y * right.y + left.z * right.z
}

/**
 * Calculates the cross product between two SCNVector3 vectors
 */
func SCNVector3CrossProduct(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.y * right.z - left.z * right.y, left.z * right.x - left.x * right.z, left.x * right.y - left.y * right.x)
}

/**
 * Calculates the SCNVector from lerping between two SCNVector3 vectors
 */
func SCNVector3Lerp(vectorStart: SCNVector3, vectorEnd: SCNVector3, t: Float) -> SCNVector3 {
  return SCNVector3Make(vectorStart.x + ((vectorEnd.x - vectorStart.x) * t), vectorStart.y + ((vectorEnd.y - vectorStart.y) * t), vectorStart.z + ((vectorEnd.z - vectorStart.z) * t))
}

/*
 angle in radians
 */
func SCNVector3Rotate(vector: SCNVector3, around: SCNVector3, radians : Float ) -> SCNVector3 {

  let rm = GLKMatrix3MakeRotation(radians, around.x, around.y, around.z);
  let v = GLKMatrix3MultiplyVector3(rm, SCNVector3ToGLKVector3(vector))
  return SCNVector3FromGLKVector3(v)

}

/**
 * Project the vector, vectorToProject, onto the vector, projectionVector.
 */
func SCNVector3Project(vectorToProject: SCNVector3, projectionVector: SCNVector3) -> SCNVector3 {
  let scale: Float = SCNVector3DotProduct(projectionVector, right: vectorToProject) / SCNVector3DotProduct(projectionVector, right: projectionVector)
  let v: SCNVector3 = projectionVector * scale
  return v
}


func SCNVector3ProjectPlane(vector: SCNVector3, planeNormal: SCNVector3 ) -> SCNVector3 {

  let projection = SCNVector3Project(vectorToProject: vector, projectionVector: planeNormal)
  return ( vector - projection )

}

func * (left: SCNMatrix4, right: Float) -> SCNMatrix4 {
  return SCNMatrix4.init(m11: left.m11 * right, m12: left.m12 * right, m13: left.m13 * right, m14: left.m14 * right,
                         m21: left.m21 * right, m22: left.m22 * right, m23: left.m23 * right, m24: left.m24 * right,
                         m31: left.m31 * right, m32: left.m32 * right, m33: left.m33 * right, m34: left.m34 * right,
                         m41: left.m41 * right, m42: left.m42 * right, m43: left.m43 * right, m44: left.m44 * right)
}

func SCNMatrix4Add( _ m1 : SCNMatrix4 , _ m2 : SCNMatrix4 ) -> SCNMatrix4 {

  return SCNMatrix4.init(m11: m1.m11 + m2.m11, m12: m1.m12 + m2.m12, m13: m1.m13 + m2.m13, m14: m1.m14 + m2.m14,
                         m21: m1.m21 + m2.m21, m22: m1.m22 + m2.m22, m23: m1.m23 + m2.m23, m24: m1.m24 + m2.m24,
                         m31: m1.m31 + m2.m31, m32: m1.m32 + m2.m32, m33: m1.m33 + m2.m33, m34: m1.m34 + m2.m34,
                         m41: m1.m41 + m2.m41, m42: m1.m42 + m2.m42, m43: m1.m43 + m2.m43, m44: m1.m44 + m2.m44)

}

func SCNMatrix4Lerp( _ m1 : SCNMatrix4 , _ m2 : SCNMatrix4, _ v : Float ) -> SCNMatrix4 {

  return SCNMatrix4.init(m11: m1.m11 + (m2.m11-m1.m11)*v, m12: m1.m12 + (m2.m12-m1.m12)*v, m13: m1.m13 + (m2.m13-m1.m13)*v, m14: m1.m14 + (m2.m14-m1.m14)*v,
                         m21: m1.m21 + (m2.m21-m1.m21)*v, m22: m1.m22 + (m2.m22-m1.m22)*v, m23: m1.m23 + (m2.m23-m1.m23)*v, m24: m1.m24 + (m2.m24-m1.m24)*v,
                         m31: m1.m31 + (m2.m31-m1.m31)*v, m32: m1.m32 + (m2.m32-m1.m32)*v, m33: m1.m33 + (m2.m33-m1.m33)*v, m34: m1.m34 + (m2.m34-m1.m34)*v,
                         m41: m1.m41 + (m2.m41-m1.m41)*v, m42: m1.m42 + (m2.m42-m1.m42)*v, m43: m1.m43 + (m2.m43-m1.m43)*v, m44: m1.m44 + (m2.m44-m1.m44)*v)

}

func SCNMatrix4GetAxesTransform( newX : SCNVector3 ,
                                 newY : SCNVector3 ,
                                 newZ : SCNVector3 ,
                                 position : SCNVector3 = .zero ) -> SCNMatrix4 {

  let transform = SCNMatrix4.init(m11: newX.x, m12: newX.y, m13: newX.z, m14: 0,
                                  m21: newY.x, m22: newY.y, m23: newY.z, m24: 0,
                                  m31: newZ.x, m32: newZ.y, m33: newZ.z, m34: 0,
                                  m41: position.x, m42: position.y, m43: position.z, m44: 1.0)
  return transform

}

// MARK: Axis aliases

extension SCNVector3 {
  enum Axis {
    case x, y, z
  }

  static let zero = SCNVector3Zero
  static let one = SCNVector3(x: 1, y: 1, z: 1)

  static let axisX = SCNVector3(x: 1, y: 0, z: 0)
  static let axisY = SCNVector3(x: 0, y: 1, z: 0)
  static let axisZ = SCNVector3(x: 0, y: 0, z: 1)
}


// MARK: - Debugging

// numpy formatting
extension SCNVector3 {
  var np: String {
    get {
      let f: (Float) -> String = { num in
        return String(format: "%.4f", num)
      }
      return "array([\(f(x)), \(f(y)), \(f(z))])"
    }
  }

  func withX(x : Float) -> SCNVector3 {
    return SCNVector3(x, self.y, self.z)
  }
  func withY(y : Float) -> SCNVector3 {
    return SCNVector3(self.x, y, self.z)
  }
  func withZ(z : Float) -> SCNVector3 {
    return SCNVector3(self.x, self.y, z)
  }


}

extension SCNMatrix4 {
  // format matrix for numpy (printed in row-major form)
  var np: String {
    get {
      let f: (Float) -> String = { num in
        return String(format: "%.4f", num)
      }
      let row1 = "[\(f(m11)), \(f(m21)), \(f(m31)), \(f(m41))]"
      let row2 = "[\(f(m12)), \(f(m22)), \(f(m32)), \(f(m42))]"
      let row3 = "[\(f(m13)), \(f(m23)), \(f(m33)), \(f(m43))]"
      let row4 = "[\(f(m14)), \(f(m24)), \(f(m34)), \(f(m44))]"
      return "\narray([\n  \(row1),\n  \(row2),\n  \(row3),\n  \(row4)\n])"
    }
  }

  var rowMajorArray : [Float] {
    get {
      let mat : [Float] = [m11, m21, m31, m41,
                           m12, m22, m32, m42,
                           m13, m23, m33, m43,
                           m14, m24, m34, m44]
      return mat
    }
  }

  var rowArrays : [[Float]] {
    get {
      return [[m11, m21, m31, m41],
              [m12, m22, m32, m42],
              [m13, m23, m33, m43],
              [m14, m24, m34, m44]]

    }
  }

  var xAxis: SCNVector3 {
    get {
      return SCNVector3(self.m11, self.m12, self.m13)
    }
    set {
      self.m11 = newValue.x
      self.m12 = newValue.y
      self.m13 = newValue.z
    }
  }
  var yAxis: SCNVector3 {
    get {
      return SCNVector3(self.m21, self.m22, self.m23)
    }
    set {
      self.m21 = newValue.x
      self.m22 = newValue.y
      self.m23 = newValue.z
    }
  }
  var zAxis: SCNVector3 {
    get {
      return SCNVector3(self.m31, self.m32, self.m33)
    }
    set {
      self.m31 = newValue.x
      self.m32 = newValue.y
      self.m33 = newValue.z
    }
  }
  var translation: SCNVector3 {
    get {
      return SCNVector3(self.m41, self.m42, self.m43)
    }
  }
  var sceneKitCameraDirection : SCNVector3 {
    return self.zAxis * -1.0
  }
}

extension matrix_float4x4 {
  // format matrix for numpy
  var np: String {
    get {
      return SCNMatrix4.init(self).np
    }
  }

  var rowMajorArray : [Float] {
    get {
      return SCNMatrix4.init(self).rowMajorArray
    }
  }
  var rowArrays : [[Float]] {
    get {
      return SCNMatrix4.init(self).rowArrays
    }
  }

}

extension matrix_float3x3 {
  var rowMajorArray : [Float] {
    get {

      let mat : [Float] = [columns.0.x, columns.1.x, columns.2.x,
                           columns.0.y, columns.1.y, columns.2.y,
                           columns.0.z, columns.1.z, columns.2.z ]
      return mat
    }
  }

  var rowArrays : [[Float]] {
    get {

      return [[columns.0.x, columns.1.x, columns.2.x],
              [columns.0.y, columns.1.y, columns.2.y],
              [columns.0.z, columns.1.z, columns.2.z] ]

    }
  }

}
