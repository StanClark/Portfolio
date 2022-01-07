using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Tilemaps;
using UnityEditor;
using UnityEngine.UI;

public class riverGenerator : MonoBehaviour
{
    [SerializeField] private GameObject LandMap;
    private float[,] Heightmap;
    public float[,] RainMapOld;
    public float[,] RainMapNew;
    public float[,] flowMap;
    private float[,,] AvgRainMap;
    private float[,,] AvgFlowMap;
    //private int[,] SymMap;
    //private int[,] SymMapOld;
    [SerializeField] private float flowThres;
    [SerializeField] private float rainRate;
    [SerializeField] private float threshold;
    [SerializeField] private Tilemap TileMap;
    [SerializeField] private Tile RiverTile;
    [SerializeField] private Tile LakeTile;
    [SerializeField] private float eroRate;
    [SerializeField] private float ForTree;
    [SerializeField] private Text raindisplay;
    
    private int sample;
    public bool ShowingTiles;


    void Start()
    {
        sample = LandMap.GetComponent<landGenerator>().sample;
        RainMapNew = new float[sample, sample];
        RainMapOld = new float[sample, sample];
        AvgRainMap = new float[sample, sample, 12];
        AvgFlowMap = new float[sample, sample, 12];
        //SymMap = new int [sample, sample];
        //SymMapOld = new int[sample, sample];
        flowMap = new float[sample, sample];
        StartCoroutine(RainCall());
        Debug.Log("Start");

        raindisplay.text = (rainRate * 100000).ToString();

    }

    public void Prec()
    {


        


        Rain(rainRate);

        Flow();
        

        ShowRivers();
    }



    private void Rain(float rainFall)
    {
        for (int i = 0; i < sample - 1; i++)
        {
            for (int j = 0; j < sample - 1; j++)
            {

                RainMapOld[i,j] += rainFall;

            }
        }
    }

    private void Flow()
    {
        Heightmap = LandMap.GetComponent<landGenerator>().Map;
        RainMapNew = new float[sample, sample];


        for (int i = 1; i < sample - 2; i++)
        {
            for (int j = 1; j < sample - 2; j++)
            {
                float[] Neighbours;
                Neighbours = new float[4];

                float Self = RainMapOld[i, j] + Heightmap[i, j];

                Neighbours[0] = RainMapOld[i - 1, j] + Heightmap[i - 1, j];
                Neighbours[1] = RainMapOld[i, j + 1] + Heightmap[i, j + 1];
                Neighbours[2] = RainMapOld[i + 1, j] + Heightmap[i + 1, j];
                Neighbours[3] = RainMapOld[i, j - 1] + Heightmap[i, j - 1];

                
                if (Heightmap[i, j] < 0.87)
                {
                    RainMapNew[i, j] = 0;
                    RainMapOld[i, j] = 0;
                }
                else if (AllHigher(Neighbours, Self))
                {
                    RainMapNew[i,j] += RainMapOld[i, j];
                    flowMap[i, j] = 0;
                }
                else
                {
                    int lowest = findLowest(Neighbours);

                    float diff = Self - Neighbours[lowest];
                    


                    float flow = Mathf.Min(RainMapOld[i, j], diff / 2);
                    flowMap[i, j] = flow / Mathf.Pow(RainMapOld[i, j], 1.2f);
                    RainMapNew[i, j] += RainMapOld[i, j] - flow;//= RainMapOld[i, j] - flow;

                    /////
                    if (RainMapOld[i, j] > ForTree & RainMapOld[i, j] < threshold & ShowingTiles)
                    {
                        Debug.DrawLine(new Vector3(i - (sample / 2) + 0.75f, j - (sample / 2) + 0.75f, 0), new Vector3(i - (sample / 2) + 0.25f, j - (sample / 2) + 0.25f, 0), Color.cyan, 0.2f);
                        
                    }
                    /////




                    if (RainMapOld[i, j] > threshold & /*RainMapOld[i, j] < threshold*25 &*/ flow * 1.1 > RainMapOld[i, j])
                    {
                        LandMap.GetComponent<landGenerator>().Erode(i, j, flow * eroRate);
                        Debug.DrawLine(new Vector3(i - (sample / 2) + 0.75f, j - (sample / 2) + 0.75f, 0), new Vector3(i - (sample / 2) + 0.25f, j - (sample / 2) + 0.25f, 0), Color.red, 0.2f);

                    }


                    switch (lowest)
                    {
                        case 0:
                            RainMapNew[i-1, j] += /*RainMapOld[i-1, j] +*/ flow;

                            
                            break;
                        case 1:
                            RainMapNew[i, j + 1] += /*RainMapOld[i, j+1]*/ + flow;

                            

                            break;
                        case 2:
                            RainMapNew[i + 1, j] += /*RainMapOld[i + 1, j]*/ + flow;

                            

                            break;
                        case 3:
                            RainMapNew[i, j-1] += /*RainMapOld[i, j-1]*/ + flow;

                            

                            break;
                    }

                    

                }

                








            }
        }

        RainMapOld = RainMapNew;

        for (int k = 11; k >= 0; k--)
        {
            if(k == 0)
            {
                for (int i = 0; i < sample - 1; i++)
                {
                    for (int j = 0; j < sample - 1; j++)
                    {

                        AvgRainMap[i, j, k] = RainMapOld[i,j];

                        AvgFlowMap[i, j, k] = flowMap[i, j];

                    }
                }
            }
            else
            {
                for (int i = 0; i < sample - 1; i++)
                {
                    for (int j = 0; j < sample - 1; j++)
                    {

                        AvgRainMap[i, j, k] = AvgRainMap[i, j, k - 1];

                        AvgFlowMap[i, j, k] = AvgFlowMap[i, j, k - 1];

                    }
                }
            }



        }
    }

    int findLowest(float[] Neighbours)
    {
        int lowest;
        lowest = 0;
        for (int i = 0; i < Neighbours.Length /*Neighbours.Length*/; i ++)
        {
            if(Neighbours[i] < Neighbours[lowest])
            {
                lowest = i;
            }
        }

        return lowest;
    }

    private void ShowRivers()
    {
        float[,] sumAvg = new float[sample, sample]; 
        float[,] sumFlowAvg = new float[sample, sample];
        //SymMap = new int[sample, sample];

        for (int k = 0; k < 12; k++)
        {
            for (int i = 0; i < sample - 1; i++)
            {
                for (int j = 0; j < sample - 1; j++)
                {

                    sumAvg[i,j] += AvgRainMap[i, j, k]/12;
                    sumFlowAvg[i, j] += AvgFlowMap[i, j, k] / 12;

                }
            }
        }



        for(int i = 0; i < sample - 1; i++)
        {
            for (int j = 0; j < sample - 1; j++)
            {

                if (sumAvg[i, j] > threshold)
                {
                    if (sumFlowAvg[i, j] > flowThres) /*SymMap[i, j] = 1;*/ TileMap.SetTile(new Vector3Int(i - (sample / 2), j - (sample / 2), 0), RiverTile);
                    else /*SymMap[i, j] = 2;*/ TileMap.SetTile(new Vector3Int(i - (sample / 2), j - (sample / 2), 0), LakeTile);

                    //Debug.Log(SymMap[i,j]);

                }
                else
                {
                    /*SymMap[i, j] = 0;*/ TileMap.SetTile(new Vector3Int(i - (sample / 2), j - (sample / 2), 0), null);
                }

            }


        }

        /* not actually useful
        for (int i = 0; i < sample - 1; i++)
        {
            for (int j = 0; j < sample - 1; j++)
            {
                Debug.Log(!(SymMapOld[i, j] == SymMap[i, j]));
                if (!(SymMapOld[i,j] == SymMap[i,j]))
                {
                    Debug.Log("switch");
                    switch (SymMap[i, j])
                    {
                        case 2:
                            TileMap.SetTile(new Vector3Int(i - (sample / 2), j - (sample / 2), 0), LakeTile);
                            Debug.Log("LAke");
                            break;
                        case 1:
                            TileMap.SetTile(new Vector3Int(i - (sample / 2), j - (sample / 2), 0), RiverTile);
                            Debug.Log("river");
                            break;
                        default:
                            TileMap.SetTile(new Vector3Int(i - (sample / 2), j - (sample / 2), 0), null);
                            break;
                    }
                }

            }


        }

        SymMapOld = SymMap; */
    }

    bool AllHigher(float[] Neighbours, float Self)
    {
        foreach(float Neighbour in Neighbours)
        {
            if(Self > Neighbour)
            {
                return false;
            }
        }

        return true;
    }


    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.Escape))
        {
            Application.Quit();
        }
    }

    private IEnumerator RainCall()
    {

        yield return new WaitForSeconds(0.2f);
        
        Prec();
        
        StartCoroutine(RainCall());
    }

    public void Reset()
    {
        RainMapOld = new float[sample, sample];
        AvgRainMap = new float[sample, sample, 12];
        AvgFlowMap = new float[sample, sample, 12];
        flowMap = new float[sample, sample];

        GameObject[] Plants = GameObject.FindGameObjectsWithTag("Tree");

        foreach (GameObject plant in Plants)
        {
            Destroy(plant);
        }
    }

    public void ChangeRain(float Amount)
    {
        rainRate += Amount;

        if (rainRate < 0) rainRate = 0;
        else if (rainRate > 4) rainRate = 4;

        raindisplay.text = (rainRate * 100000).ToString();
    }


}
