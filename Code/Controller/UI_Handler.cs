using System;
using System.Collections.Generic;
using UnityEngine;


public class UI_Handler : MonoBehaviour
{
    Data data;

    void Awake()
    {
        data = gameObject.AddComponent<Data>();
    }

    public List<bool> activate(int x, int y)
    {
        // Debug.Log(x);
        // Debug.Log(y);
        return data.Maps_Render(x, y);
    }

}


// generate populasi pertama
// populasi