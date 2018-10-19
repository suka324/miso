using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScanField : MonoBehaviour {

    bool isAdd = true;

	// Use this for initialization
	void Start ()
    {
        ParameterTable.Instance.range = 0.0f;
    }
	
	// Update is called once per frame
	void Update ()
    {
        /*
        if (isAdd)
        {
            ParameterTable.Instance.range += Time.deltaTime * 20.0f;
            if (ParameterTable.Instance.range >= 100.0f)
            {
                ParameterTable.Instance.range = 100.0f;
                isAdd = false;
            }
        }
        else
        {
            ParameterTable.Instance.range -= Time.deltaTime * 20.0f;
            if (ParameterTable.Instance.range <= 0.0f)
            {
                ParameterTable.Instance.range = 0.0f;
                isAdd = true;
            }
        }
        */

        float range = ParameterTable.Instance.range * 2.0f;
        transform.localScale = new Vector3(range, range, range);
    }
}
