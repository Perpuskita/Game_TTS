using System.Collections.Generic;
using UnityEngine;


public class UI_Handler : MonoBehaviour
{

    Spawn_Grid UI;
    Data data;

    void Awake()
    {
        data = gameObject.AddComponent<Data>();
    }

    public List<bool> activate()
    {
        return data.Maps_Render(3, 3);
    }

}