using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SearchScript : MonoBehaviour {

	// Use this for initialization
	void Start () {
    }
	
	// Update is called once per frame
	void Update ()
    {
        float range = ParameterTable.Instance.range;
        ParameterTable.Instance.Material0.SetFloat("_Range", range);    // 湾曲
        ParameterTable.Instance.Material1.SetFloat("_Range", range);    // 色変え
        ParameterTable.Instance.Material2.SetFloat("_Range", range);    //
        ParameterTable.Instance.Material3.SetFloat("_Range", range);    //
    }
}
