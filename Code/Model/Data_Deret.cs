using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor.Experimental.GraphView;
using UnityEngine;

// MODEL CLASS UNTUK DATA DERET
// DIAKSES UNTUK MENYIMPAN DATA DARI GENERATED MODEL TTS

public class Data_Deret : MonoBehaviour
{
    private string kata;
    private bool direction;
    private int x;
    private int y;

    public Data_Deret(string kata, bool direction, int x, int y)
    {
        this.kata = kata;
        this.direction = direction;
        this.x = x;
        this.y = y;
    }

    public string Get()
    {
        return kata;
    }

    public int String_Length()
    {
        return kata.Length;
    }

    public List<Vector2> Get_Render()
    {
        List<Vector2> Temp = new List<Vector2>();
        if (direction)
        {
            for (int i = 0; i < String_Length(); i++)
            {
                
            }

            return Temp;
        }
        else
        {
            for (int i = 0; i < String_Length(); i++)
            {

            }

            return Temp;
        }
        
    }
    public bool Get_Direction()
    {
        return direction;
    }

}
