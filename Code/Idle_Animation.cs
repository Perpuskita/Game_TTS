using UnityEngine;

public class Idle_Animation : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    [Header("Hover Settings")]
    public float hoverHeight = 0.2f;    // Max distance to hover up/down from start position
    public float hoverSpeed = 1.0f;     // Speed of the hover animation (cycles per second)
    public float hoverOffset = 0.0f;    // Adds an offset to the animation phase (useful for syncing multiple hovers)

    private Vector3 startPosition;      // The initial position of the object

    void Start()
    {
        // Store the object's initial position when the game starts
        startPosition = transform.position;
    }

    void Update()
    {
        // Calculate the new Y position using a sine wave
        // Time.time gives a continuous increasing value
        // hoverSpeed controls how fast the sine wave cycles
        // hoverOffset shifts the starting point of the sine wave
        // Mathf.Sin() returns a value between -1 and 1
        // Multiply by hoverHeight to get the desired amplitude of the hover
        float newY = startPosition.y + Mathf.Sin((Time.time + hoverOffset) * hoverSpeed) * hoverHeight;

        // Apply the new Y position, keeping X and Z the same as the start position
        transform.position = new Vector3(startPosition.x, newY, startPosition.z);
    }
}
