using System;
using System.Collections.Generic;
using Unity.Collections;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using System.Linq;

public class Data : MonoBehaviour
{
    // Class container dari data deret
    private List<Data_Deret> datas;
    public Data()
    {
        datas = Spawn_Data();
    }

    private List<Data_Deret> Spawn_Data()
    {
        Data_Deret x1 = new Data_Deret("KA", true, 0, 0);
        Data_Deret y1 = new Data_Deret("KUA", false, 0, 0);
        Data_Deret x2 = new Data_Deret("AKU", true, 0, 2);
        return new List<Data_Deret> { x1, y1, x2 };
    }

    public List<bool> Maps_Render(int length, int height)
    {
        List<bool> temp = Enumerable.Repeat(false, height * length).ToList();

        // Debug.Log(length);
        // Debug.Log(datas.Count);

        foreach (Data_Deret item in datas)
        {
            Vector2 Coordinate = item.Get_Render();

            // Mendatar
            if (item.Get_Direction())
            {
                for (int i = 0; i < item.String_Length(); i++)
                {
                    // Debug.Log((int)Coordinate.x + i + (int)Coordinate.y * length);
                    temp[(int)Coordinate.x + i + (int)Coordinate.y * length] = true;
                }

            }
            
            // Menurun
            else
            {
                for (int i = 0; i < item.String_Length(); i++)
                {
                    // Debug.Log((int)Coordinate.x + length * (i + (int)Coordinate.y));
                    temp[(int)Coordinate.x + length * (i + (int)Coordinate.y)] = true;
                }
            }
        }

        // Cek Hasil dari Temp 
        // foreach (bool item in temp)
        // {
        //     Debug.Log(item);
        // }

        return temp;
    }

    private List<bool> Maps_Render_solo(int height, int length)
    {

        return new List<bool>(height * length);
    }

    public bool Searching_Data(string kata, int x, int y)
    {
        return false;
    }

    public List<Vector2> Searching_Grid( Vector2 coordinate)
    {
        List<Vector2> temp = null;
        Debug.Log(coordinate);

        foreach (Data_Deret item in datas)
        {
            List<Vector2> cek = item.Get_Render(coordinate);

            if (cek != null)
            {
                temp = cek;

                if (item.Get_Direction())
                {
                    // Debug.Log("Mendatar + break : " + item.Get_String());
                    break;
                }
                // else
                // {
                //     Debug.Log("Menurun + no break : " + item.Get_String());
                // }
            }
        }

        if (temp != null)
        {
            return temp;
        }
        else
        {
            return null;
        }
    }

    public Data_Deret GetData_by_index(int index)
    {
        return datas[index];
    }

    public bool Check_Answer(string kata)
    {
        foreach (Data_Deret deret in datas)
        {
            if (string.Compare(deret.Get_String(), kata) == 1)
            {
                Debug.Log("ppp");
            }
        }

        return false;
    }



}
