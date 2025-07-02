using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor.Experimental.GraphView;
using UnityEngine;

// MODEL CLASS UNTUK DATA DERET
// DIAKSES UNTUK MENYIMPAN DATA DARI GENERATED MODEL TTS

public class Data_Deret : MonoBehaviour
{
    private string kata;    // String berisi kata yang digunakan dalam TTS
    private bool direction; // True untuk mendatar dan False untuk menurun
    private int x;          // Koordinat x dari data
    private int y;          // Koordinat y dari data

    public Data_Deret(string kata, bool direction, int x, int y)
    {
        this.kata = kata;
        this.direction = direction;
        this.x = x;
        this.y = y;
    }

    public string Get_String()
    {
        return kata;
    }

    public int String_Length()
    {
        return kata.Length;
    }

    public Vector2 Get_Render()
    {
        
        return new Vector2(x,y);
        
    }

    public bool Get_Direction()
    {
        return direction;
    }

}
