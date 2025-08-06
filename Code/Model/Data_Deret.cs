using System.Collections.Generic;
using UnityEngine;

// MODEL CLASS UNTUK DATA DERET
// DIAKSES UNTUK MENYIMPAN DATA DARI GENERATED MODEL TTS

public class Data_Deret : MonoBehaviour
{
    private string kata;    // String berisi kata yang digunakan dalam TTS
    private bool direction; // True untuk mendatar dan False untuk menurun
    private int x;          // Koordinat x dari data
    private int y;          // Koordinat y dari data
    private bool clear;     // variabel untuk mengetahui apakah kata sudah tertebak 

    public Data_Deret(string kata, bool direction, int x, int y)
    {
        this.kata = kata;
        this.direction = direction;
        this.x = x;
        this.y = y;
        clear = false;
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

    public List<Vector2> Get_Render( Vector2 coordinate )
    {
        List<Vector2> temp = new List<Vector2>();
        bool found = false;
        
        for (int i = 0; i < kata.Length; i++)
        {
            if (direction && !clear)
            {
                temp.Add(new Vector2(x + i, y));

                if (coordinate.x == x + i && coordinate.y == y)
                {
                    //Debug.Log(coordinate);
                    found = true;
                }
            }
            else
            {
                temp.Add(new Vector2(x, y + i));

                if (coordinate.x == x && coordinate.y == y + i)
                {
                    //Debug.Log(coordinate);
                    found = true;
                }
            }
        }
 
        if (found)
        {
            return temp;
        }
        else
        {
            return null;
        }

        
    }

    public bool Get_Direction()
    {
        return direction;
    }

}
