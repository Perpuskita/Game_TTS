using System;
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

    public List<bool> activate(int x, int y)
    {
        // Debug.Log(x);
        // Debug.Log(y);
        return data.Maps_Render(x, y);
    }

    public List<string> activate(int x, int y, string a)
    {
        return new List<string>();
    }

}