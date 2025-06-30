using System.Collections.Generic;
using UnityEngine;

public class Spawn_Grid : MonoBehaviour
{

    // Konfigurasi grid

    [Header("Grid Configuration")]
    const float grid_position = 0;
    private List<GameObject> Grid_Obj;
    [SerializeField] GameObject Grid_Reference;
    [SerializeField, Range(1, 10)] int grid_length;
    [SerializeField, Range(1, 10)] int grid_height;
    [SerializeField, Range(0, 3)] float gap;

    private Vector2 dimension;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        Grid_Obj = new List<GameObject>();
        dimension = new Vector2(Grid_Reference.GetComponent<MeshRenderer>().bounds.size.x, Grid_Reference.GetComponent<MeshRenderer>().bounds.size.y);

        for (int i = 0; i < grid_length; i++)
        {
            for (int j = 0; j < grid_length; j++)
            {
                // Debug.Log(j - grid_length / 2);
                // Debug.Log(i);

                spawn_grid(Grid_Reference, j - grid_length / 2, i);

            }
        }
    }

    public Vector2 Get_Dimensions_Reference()
    {
        return dimension;
    }

    void spawn_grid(GameObject reference, int x, int y)
    {
        GameObject new_grid = Instantiate(reference);
        new_grid.transform.SetParent(reference.transform.parent);
        new_grid.transform.position = new Vector3(  dimension.x * x + gap * x,
                                                    dimension.y * y + gap * y,
                                                    grid_position   );

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
