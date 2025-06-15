using UnityEngine;
using UnityEngine.UI;

public class FPS_Counter : MonoBehaviour
{
    [Tooltip("The TextMeshPro UI element to display the FPS.")]
    public Text fpsText;

    [Tooltip("Interval in seconds to update the FPS display.")]
    [Range(0.1f, 1.0f)] // Restrict to a reasonable range
    public float updateInterval = 0.5f; // Update every half-second

    [Tooltip("Color of the text when FPS is good.")]
    public Color goodFpsColor = Color.green;
    [Tooltip("FPS threshold for 'good' color.")]
    public int goodFpsThreshold = 60;

    [Tooltip("Color of the text when FPS is moderate.")]
    public Color moderateFpsColor = Color.yellow;
    [Tooltip("FPS threshold for 'moderate' color.")]
    public int moderateFpsThreshold = 30;

    [Tooltip("Color of the text when FPS is bad.")]
    public Color badFpsColor = Color.red;

    // private float accum = 0; // FPS accumulated over the interval
    private int frames = 0; // Frames drawn over the interval
    private float timeleft; // Left time for current interval

    void Start()
    {
        // Initialize timeleft with the update interval
        timeleft = updateInterval;

        // Basic error check: ensure the TextMeshProUGUI component is assigned
        if (fpsText == null)
        {
            Debug.LogError("FPSCounter: fpsText TextMeshProUGUI component is not assigned. Please assign it in the Inspector.", this);
            enabled = false; // Disable the script if no text component
            return;
        }
    }

    void Update()
    {
        // Decrement timeleft by the time elapsed since the last frame
        timeleft -= Time.deltaTime;
        // Increment frame count
        ++frames;

        // If the interval has passed
        if (timeleft <= 0.0f)
        {
            // Calculate FPS: frames / time elapsed
            float fps = frames / (updateInterval - timeleft); // (updateInterval - timeleft) is the actual time passed in the interval

            // Determine text color based on FPS
            if (fps >= goodFpsThreshold)
            {
                fpsText.color = goodFpsColor;
            }
            else if (fps >= moderateFpsThreshold)
            {
                fpsText.color = moderateFpsColor;
            }
            else
            {
                fpsText.color = badFpsColor;
            }

            // Update the UI text
            fpsText.text = $"FPS: {Mathf.RoundToInt(fps)}"; // Display as an integer

            // Reset for the next interval
            timeleft = updateInterval;
            // accum = 0; // Not strictly needed if not calculating average, but good practice
            frames = 0;
        }
    }
}
