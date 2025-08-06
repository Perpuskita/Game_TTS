using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using TMPro;
using Unity.VisualScripting;
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

    // Konfigurasi Overlay
    [SerializeField] private GameObject Selected_Overlay;
    List<GameObject> Overlay_Container;

    // UI Handler variable
    private UI_Handler UI;


    // Dimensi dari Game Obj Grid  yang belum digenerate
    private Vector2 dimension;


    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        // Grid obj inisialisasi
        // UI Handler Get Component
        // Overlay Container inisialisasi 
        Grid_Obj = new List<GameObject>();
        UI = gameObject.GetComponent<UI_Handler>();
        Overlay_Container = new List<GameObject>();

        // Get dimension dari Referensi Grid
        dimension = new Vector2(Grid_Reference.GetComponent<MeshRenderer>().bounds.size.x,
                                Grid_Reference.GetComponent<MeshRenderer>().bounds.size.y);

        // Loop untuk spawn grid pertama, contoh :
        // 3,-1 | 3, 0 | 3,1
        // 2,-1 | 2, 0 | 2,1
        // 1,-1 | 1, 0 | 1,1

        for (int i = grid_height; i > 0; i--)
        {
            for (int j = 0; j < grid_length; j++)
            {
                // Debug.Log(j - grid_length / 2 - 1 + " " + ( i - 1 ));
                spawn_grid(Grid_Reference, j - grid_length / 2, i - 1);
                
            }
        }

        // Set active Grid Setelah inisialisasi spawn pertama
        set_activate_grid(UI.activate(grid_length,grid_height));
         
    }

    public Vector2 Get_Dimension_Grid()
    {
        return new Vector2(grid_length, grid_height);
    }

    public float Get_Gap()
    {
        return gap;
    }

    public Vector2 Get_Dimensions_Reference()
    {
        return dimension;
    }

    public void set_activate_grid(List<bool> activated)
    {
        // Cek grid yang diaktifkan
        // foreach (var item in activated)
        // {
        //     print(item);
        // }

        for (int i = 0; i < activated.Count; i++)
        {
            // Grid_Obj[i].GetComponent<TextMeshPro>().text = " ";
            if (activated[i])
            {
                Grid_Obj[i].SetActive(true);
            }
            else
            {
                Grid_Obj[i].SetActive(false);
            }
        }
    }

    public IEnumerator set_activate_overlay( Vector2 coordinate )
    {

        float x = coordinate.x - grid_length / 2 ;
        float y = grid_height - coordinate.y - 1 ;

        // Debug.Log(x);

        // spawn new grid
        GameObject new_grid = Instantiate(Selected_Overlay);
        new_grid.transform.SetParent(Selected_Overlay.transform.parent);
        new_grid.transform.position     = new Vector3(  dimension.x * x + gap * x,
                                                        dimension.y * y + gap * y,
                                                        Selected_Overlay.transform.position.z);

        new_grid.transform.localScale   = new Vector3(  dimension.x ,
                                                        dimension.y,
                                                        1);
        // new_grid.GetComponentInChildren<TextMeshPro>().text = "";
        // new_grid.SetActive(false);
        // Grid_Obj.Add(new_grid);

        Overlay_Container.Add(new_grid);

        yield return null;
    }

    public IEnumerator set_activate_overlay()
    {
        // Overlay 
        while (Overlay_Container.Count > 0)
        {
            GameObject item = Overlay_Container[0];
            Overlay_Container.RemoveAt(0); // Remove from list first
            Destroy(item);
        }
        yield return null;    
    }


    public void set_activate_grid(string kata)
    {

    }

    private void spawn_grid(GameObject reference, float x, float y)
    {

        // Debug.Log("Koordinat Spawn : " + x + " , " + y);

        // Spawn Grid dengan referensi
        GameObject new_grid = Instantiate(reference);
        new_grid.transform.SetParent(reference.transform.parent);
        new_grid.transform.position = new Vector3(  dimension.x * x + gap * x,
                                                    dimension.y * y + gap * y,
                                                    grid_position);
        new_grid.GetComponentInChildren<TextMeshPro>().text = "";
        new_grid.SetActive(false);
        Grid_Obj.Add(new_grid);

    }

}
