using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TimeScaler : MonoBehaviour
{
    private float timeScale;
    [SerializeField] private Text display;

    void Start()
    {
        timeScale = 1;
    }


    public void multiply(float m)
    {
        timeScale *= m;
        if (timeScale > 64) timeScale = 64;
        else if (timeScale < 0.25f) timeScale = 0.25f;
        Time.timeScale = timeScale;
        display.text = "x" + timeScale.ToString();
    }
}
