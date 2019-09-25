using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using UnityEngine;
using Newtonsoft.Json;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;


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

	public lb_BirdController birdController;
	public lb_Bird bird;

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
		bird.SendMessage("SetController", birdController);
        
		birdController.SendMessage("AllPause");
	}

    public void UpdatePose(string message)
	{
		var poses = FritzPoseManager.ProcessEncodedPoses(message);

		foreach (FritzPose pose in poses)
		{
			var bodyPoint = WorldPointForPart(pose, trackedPart);
			MoveBirdToPoint(bird, bodyPoint);
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

#if UNITY_ANDROID && !UNITY_EDITOR

        XRCameraImage image;
        if (!cameraManager.TryGetLatestImage(out image))
        {
            image.Dispose();
            return;
        }

        FritzPoseManager.ProcessImageAsync(image);

        // You must dispose the CameraImage to avoid resource leaks.
        image.Dispose();

#elif UNITY_IOS && !UNITY_EDITOR
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

        FritzPoseManager.ProcessPoseAsync(frame.nativePtr);

#else
        var randomPosition = debugPoint;
		randomPosition.x = randomPosition.x * UnityEngine.Random.Range(-0.5f, 0.5f);
		randomPosition.y = randomPosition.y * UnityEngine.Random.Range(-0.5f, 0.5f);

		Debug.LogFormat("{0}", bird);
		MoveBirdToPoint(bird, randomPosition);
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
		var y = 1.0f - keypoint.position.y;
		
		var position = new Vector3(x, y, 1f);
		return m_Cam.ViewportToWorldPoint(position);
	}

	void MoveBirdToPoint(lb_Bird bird, Vector3 position)
	{
		var distance = Vector3.Distance(bird.transform.position, position);

		if (!bird.flying && !bird.landing && distance > .1f)
		{
			Debug.LogFormat("Starting to fly to {0}", position);
			bird.SendMessage("FlyToTarget", position);
		}
		else if (bird.onGround && distance < 0.1f && position.x > bird.transform.position.x)
		{
            if (distance > 0.05f)
			{
				bird.SendMessage("DisplayBehavior", lb_Bird.birdBehaviors.hopLeft);
			}
            else
			{
				bird.transform.position = Vector3.Lerp(bird.transform.position, position, Time.deltaTime);
			}
			var rotation = Quaternion.LookRotation(m_Cam.transform.position - bird.transform.position);
			bird.transform.rotation = Quaternion.Slerp(bird.transform.rotation, rotation, Time.deltaTime);
		}
		else if (bird.onGround && distance < 0.1f && position.x < bird.transform.position.x)
		{
            if (distance > 0.05f)
			{
				bird.SendMessage("DisplayBehavior", lb_Bird.birdBehaviors.hopRight);
			}
			else
			{
				bird.transform.position = Vector3.Lerp(bird.transform.position, position, Time.deltaTime);
			}
			var rotation = Quaternion.LookRotation(m_Cam.transform.position - bird.transform.position);
			bird.transform.rotation = Quaternion.Slerp(bird.transform.rotation, rotation, Time.deltaTime * 10f);
		}




		return;
	}


}
