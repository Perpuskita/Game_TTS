using UnityEngine;

public class Player_Handler : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        Data su = new Data();
        Debug.Log(su.Maps_Render(3,3));
        zoom fe = gameObject.GetComponent<zoom>();

    }

}
