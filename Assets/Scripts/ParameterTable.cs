using System;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObjects/ParameterTable", fileName = "ParameterTable")]
public sealed class ParameterTable : ScriptableObject
{
    private static readonly string RESOURCE_PATH = "ParameterTable";

    private static ParameterTable instance_ = null;
    public static ParameterTable Instance
    {
        get
        {
            if (instance_ == null)
            {
                var asset = Resources.Load(RESOURCE_PATH) as ParameterTable;
                if (asset == null)
                {
                    Debug.AssertFormat(false, "Missing ParameterTable! path={0}", RESOURCE_PATH);
                    asset = CreateInstance<ParameterTable>();
                }
                instance_ = asset;
            }

            return instance_;
        }
    }

    [Header("MATERIAL")]
    [SerializeField] public Material Material0;
    [SerializeField] public Material Material1;
    [SerializeField] public Material Material2;
    [SerializeField] public Material Material3;
    [SerializeField, Range(0.0f, 100.0f)] public float range;

} // class ParameterTable