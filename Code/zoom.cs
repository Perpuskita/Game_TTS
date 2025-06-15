using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using UnityEngine.LowLevelPhysics;
using UnityEngine.InputSystem;
using Unity.Mathematics;

public class zoom : MonoBehaviour
{
    // const position untuk 
    const float bg = -40;
    const float ornament = -10;
    const float grid = 0;

    // Obj and Camera definition

    [Header("Object Definition")]
    [SerializeField] private Camera cam;
    [SerializeField] private GameObject Background;
    [SerializeField] private List<GameObject> Ornaments;
    [SerializeField] private List<GameObject> Grid_Obj;

    // Future update for fake smile concept
    [SerializeField] private GameObject Selected_Overlay;


    [Header("Grid Configuration")]
    [SerializeField, Range(1, 10)] int grid_length;
    [SerializeField, Range(1, 10)] int grid_height;
    [SerializeField, Range(0, 3)] float gap;

    private Vector2 dimension;
    bool on_animate;



    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {

        on_animate = false;
        // setting background
        setting_background_position();

        // dimensi untuk mesh renderer Grid Component
        dimension = new Vector2(Grid_Obj[0].GetComponent<MeshRenderer>().bounds.size.x, Grid_Obj[0].GetComponent<MeshRenderer>().bounds.size.y);

        // i untuk pos y
        // j untuk pos x

        for (int i = 0; i < grid_length; i++)
        {
            for (int j = 0; j < grid_length; j++)
            {
                // Debug.Log(j - grid_length / 2);
                // Debug.Log(i);

                spawn_grid(Grid_Obj[0], j - grid_length / 2, i);

            }
        }

        StartCoroutine(highlight(45, 60));

    }

    void setting_background_position()
    {
        Background.transform.position = new Vector3(0, 0, bg);
        foreach (GameObject item in Ornaments)
        {
            item.transform.position = new Vector3(item.transform.position.x,
                                                    item.transform.position.y,
                                                    ornament);
        }
    }

    void spawn_grid(GameObject reference, int x, int y)
    {
        GameObject new_grid = Instantiate(reference);
        new_grid.transform.SetParent(reference.transform.parent);
        new_grid.transform.position = new Vector3(dimension.x * x + gap * x,
                                                    dimension.y * y + gap * y,
                                                    grid);

    }
    // Update is called once per frame
    void Update()
    {

    }

    public void Onklick(InputAction.CallbackContext ctx)
    {

        Vector2 touchPosition = ctx.ReadValue<Vector2>();
        Vector2 worldPosition = cam.ScreenToWorldPoint(new Vector2(touchPosition.x, touchPosition.y));

        if (ctx.phase == InputActionPhase.Started)
        {
            Debug.Log("World Position: " + worldPosition);

        }

        // Debug.Log(ctx.ReadValue<Vector2>());
        // Debug.Log(ctx.phase);

        

        if (!on_animate && ctx.phase == InputActionPhase.Started)
        {
            if (cam.orthographicSize == 60)
            {
                StartCoroutine(highlight(60, 45));
                StartCoroutine(overlay(worldPosition, mendatar : 1));
            }
            else
            {
                StartCoroutine(overlay());
                StartCoroutine(highlight(45, 60));
            }
        }
    }

    // Future update for fake smile concept

    IEnumerator overlay( Vector3 coordinate, int mendatar = 1, int menurun = 1 )
    {
        Selected_Overlay.transform.position     = new Vector3(  math.floor((coordinate.x + dimension.x / 2) / dimension.x ) * ( dimension.x + gap),
                                                                math.floor((coordinate.y + dimension.y / 2) / dimension.y ) * ( dimension.y + gap),
                                                                -5);

        Selected_Overlay.transform.localScale   = new Vector3(  dimension.x* mendatar + gap* mendatar,
                                                                dimension.y* menurun + gap* menurun,
                                                                1);
        yield return null; 
    }

    IEnumerator overlay()
    {
        Selected_Overlay.transform.localScale = Vector3.zero;
        yield return null;
    }

    IEnumerator highlight(float startSize, float endSize, float duration = 0.5f)
    {
        on_animate = true;
        float elapsedTime = 0f;

        while (elapsedTime < duration)
        {
            // Calculate interpolation factor (0 to 1)
            float t = elapsedTime / duration;

            // Optionally use easing function for smoother transition
            t = (Mathf.Sin((t * Mathf.PI) - Mathf.PI / 2f) + 1f) * 0.5f;

            // Interpolate between start and end size
            cam.orthographicSize = Mathf.Lerp(startSize, endSize, t);

            elapsedTime += Time.deltaTime;
            yield return null;
        }

        // Ensure exact final value
        cam.orthographicSize = endSize;
        on_animate = false;
    }
}
