using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using UnityEngine;
using Newtonsoft.Json;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using UnityEngine.Android;


public class FritzVisionUnity : MonoBehaviour
{

    [SerializeField]
    [Tooltip("The ARCameraManager which will produce frame events.")]
    ARCameraManager m_CameraManager;

    public ARCameraManager cameraManager
    {
        get => m_CameraManager;
        set => m_CameraManager = value;
    }

    [SerializeField]
    Camera m_Cam;

    [SerializeField]
    GameObject trackedObject;

    [SerializeField]
    FritzPoseParts trackedPart;

    [SerializeField]
    Vector3 debugPoint = new Vector3(0.1f, 0.1f, 3f);

    #region Singleton implementation

    private static FritzVisionUnity _instance;

    public static FritzVisionUnity Instance
    {
        get
        {
            if (_instance == null)
            {
                var obj = new GameObject("FritzPoseUnity");
                _instance = obj.AddComponent<FritzVisionUnity>();
            }

            return _instance;
        }
    }


    #endregion

    private void Awake()
    {
      
        if (_instance != null)
        {
            Destroy(gameObject);
            return;
        }

        DontDestroyOnLoad(gameObject);
        FritzPoseManager.Configure();
        FritzPoseManager.SetCallbackTarget("FritzPoseController");
        FritzPoseManager.SetCallbackFunctionTarget("UpdatePose");
	}

    public void UpdatePose(string message)
    {
        List<FritzPose> poses = FritzPoseManager.ProcessEncodedPoses(message);

        foreach (FritzPose pose in poses)
        {
            var bodyPoint = WorldPointForPart(pose, trackedPart);

            if (trackedObject != null)
            {
                trackedObject.transform.position = bodyPoint;
            }

            break;
        }
    }

    private void Update()
    {
        if (FritzPoseManager.Processing())
        {
            return;
        }

#if UNITY_ANDROID

		XRCameraImage image;
		if (!cameraManager.TryGetLatestImage(out image))
		{
			image.Dispose();
			return;
		}

		FritzPoseManager.ProcessPoseFromImageAsync(image);

        // You must dispose the CameraImage to avoid resource leaks.
        image.Dispose();

#elif UNITY_IOS
        var cameraParams = new XRCameraParams
		{
			zNear = m_Cam.nearClipPlane,
			zFar = m_Cam.farClipPlane,
			screenWidth = Screen.width,
			screenHeight = Screen.height,
			screenOrientation = Screen.orientation
		};

        XRCameraFrame frame;

        if (!cameraManager.subsystem.TryGetLatestFrame(cameraParams, out frame))
		{
		    return;
		}

        FritzPoseManager.ProcessPoseFromFrameAsync(frame);
#else
        var randomPosition = debugPoint;
        randomPosition.x = randomPosition.x * UnityEngine.Random.Range(-0.5f, 0.5f);
        randomPosition.y = randomPosition.y * UnityEngine.Random.Range(-0.5f, 0.5f);

        if (trackedObject != null)
        {
            trackedObject.transform.position = randomPosition;
        }
#endif
    }

    Vector3 WorldPointForPart(FritzPose pose, FritzPoseParts posePart)
    {
        Keypoint keypoint = pose.keypoints[(int)posePart];
        var x = keypoint.position.x;
        // Unity coordinates are (0,0) in bottom left, iOS is (0, 0) top left
        var y = 1.0f - keypoint.position.y;
        var position = new Vector3(x, y, 2f);
        var output = m_Cam.ViewportToWorldPoint(position);
        return output;
    }
}
