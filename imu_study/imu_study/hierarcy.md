Core Motion Framework
│
├── 📱 Raw Motion Sensors
│   └── 🏛️ CMMotionManager
│       │
│       ├── ⚙️ startAccelerometerUpdates()
│       │   └── 🏛️ CMAccelerometerData : CMLogItem
│       │       ├── 🔹 timestamp: TimeInterval
│       │       └── 🔹 acceleration: 📦 CMAcceleration
│       │           ├── 🔹 x: Double
│       │           ├── 🔹 y: Double
│       │           └── 🔹 z: Double
│       │
│       ├── ⚙️ startGyroUpdates()
│       │   └── 🏛️ CMGyroData : CMLogItem
│       │       ├── 🔹 timestamp
│       │       └── 🔹 rotationRate: 📦 CMRotationRate
│       │           ├── 🔹 x, y, z: Double
│       │
│       ├── ⚙️ startMagnetometerUpdates()
│       │   └── 🏛️ CMMagnetometerData : CMLogItem
│       │       ├── 🔹 timestamp
│       │       └── 🔹 magneticField: 📦 CMMagneticField
│       │           ├── 🔹 x, y, z: Double
│       │
│       └── ⚙️ startDeviceMotionUpdates()  ⭐
│           └── 🏛️ CMDeviceMotion : CMLogItem
│               ├── 🔹 timestamp
│               ├── 🔹 attitude: 🏛️ CMAttitude
│               │   ├── 🔹 roll: Double
│               │   ├── 🔹 pitch: Double
│               │   ├── 🔹 yaw: Double
│               │   ├── 🔹 quaternion: 📦 CMQuaternion (x,y,z,w)
│               │   └── 🔹 rotationMatrix: 📦 CMRotationMatrix (3×3)
│               ├── 🔹 rotationRate: 📦 CMRotationRate
│               ├── 🔹 gravity: 📦 CMAcceleration
│               ├── 🔹 userAcceleration: 📦 CMAcceleration
│               ├── 🔹 magneticField: 📦 CMCalibratedMagneticField
│               │   ├── 🔹 field: 📦 CMMagneticField
│               │   └── 🔹 accuracy: 🔢 CMMagneticFieldCalibrationAccuracy
│               │       (uncalibrated / low / medium / high)
│               └── 🔹 heading: Double
│
