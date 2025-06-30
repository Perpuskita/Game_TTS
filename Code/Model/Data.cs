using System;
using System.Collections.Generic;
using Unity.Collections;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering.Universal;

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
        Data_Deret x1 = new Data_Deret("KAU", true, 0, 0);
        Data_Deret y1 = new Data_Deret("KUA", false, 0, 0);
        Data_Deret x2 = new Data_Deret("AKU", true, 0, 0);
        return new List<Data_Deret>{x1, y1, x2};
    }

    public List<bool> Maps_Render( int height, int length )
    {

        List<bool> temp = new List<bool>();
        Debug.Log(datas.Count);

        foreach (Data_Deret item in datas)
        {
            if (item.Get_Direction())
            {
                //Debug.Log(item.String_Length() + " " + item.Get());
                for (int i = 0; i < item.String_Length(); i++)
                {
                    temp[0] = true;
                }
            }
            else
            {
                //Debug.Log(item.String_Length() + " " + item.Get());
            }
        }

        return new List<bool>(height*length);
    }

    private List<bool> Maps_Render_solo(int height, int length)
    {

        return new List<bool>(height * length);
    }

    public bool Searching_Data(string kata, int x, int y)
    {

        return false;
    }

    public Data_Deret GetData_by_index(int index)
    {
        return datas[index];
    }

    public bool Check_Answer(string kata)
    {
        foreach (Data_Deret deret in datas)
        {
            if (string.Compare(deret.Get(), kata) == 1)
            {
                Debug.Log("ppp");
            }
        }

        return false;
    }
    


}
