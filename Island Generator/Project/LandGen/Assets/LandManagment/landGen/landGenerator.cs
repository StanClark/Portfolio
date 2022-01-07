using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Tilemaps;

public class landGenerator : MonoBehaviour
{
    // Start is called before the first frame update
    public int sample;
    public float[,] Map;
    [SerializeField] private float[] range;
    [SerializeField] private float[] Amp;
    [SerializeField] private Tilemap TileMap;
    [SerializeField] private float regressionRate;
    

    [System.Serializable] // allows spawn info to be serialized
    public class TileChart // creates variable which contains vector 3 and a gameobject
    {
        public Tile Tile;
        public float Cutoff;
    }

    public TileChart[] Tiles;



    void Start()
    { 
        Map = new float[sample - 1, sample - 1];
       
        genHeightMap();

        tileHeightMap();

        
    }

    private void genHeightMap()
    {
        Map = addMaps(generateMap(range[0], Amp[0]), generateMap(range[1], Amp[1]), generateMap(range[2], Amp[2]));
    }

    private void tileHeightMap()
    {
        for (int i = 0; i < sample - 1; i++)
        {
            for (int j = 0; j < sample - 1; j++)
            {

                TileMap.SetTile(new Vector3Int(i-(sample/2),j-(sample/2),0),Picktile(Map[i,j]));
                
            }
        }
    }

    Tile Picktile(float Height)
    {
        Tile tile;
        tile = Tiles[Tiles.Length -1].Tile;
        for (int i = 0; i < Tiles.Length -1; i++)
        {
            if(Tiles[i].Cutoff <= Height)
            {
                tile = Tiles[i].Tile;
                //Debug.Log(Height);
                break;
            }
            
        }

        return tile;
    }

    float[,] generateMap(float range, float Amp)
    {
        float[,] result;
        result = new float[sample - 1, sample - 1];

        Vector2 start = new Vector2(Random.Range(-10000, 10000), Random.Range(-10000, 10000));
        float Inc = range / sample;

        for (int i = 0; i < sample - 1; i++)
        {
            for (int j = 0; j < sample - 1; j++)
            {

                result[i, j] = Mathf.PerlinNoise(start.x + Inc * i, start.y + Inc * j) * Amp - Mathf.Pow(new Vector2(i- (sample / 2), j- (sample / 2)).magnitude/(sample*1.2f), regressionRate);

            }
        }

        return result;

    }

    float[,] addMaps(float[,] m1, float[,] m2, float[,] m3)
    {
        float[,] map = new float[sample - 1, sample - 1];

        for (int i = 0; i < sample - 1; i++)
        {
            for (int j = 0; j < sample - 1; j++)
            {

                map[i, j] = m1[i, j] + m2[i, j] + m3[i, j];

            }
        }

        return map;
    }

    public void Erode(int i, int j, float erode)
    {
        Map[i, j] = Mathf.Max(Map[i, j] - erode, 0.87f);
        tileHeightMap();
    }



    // Update is called once per frame
    void Update()
    {
        /*
        if (Input.GetKeyDown(KeyCode.R))
        {
            genHeightMap();

            tileHeightMap();
        }*/

        if (Input.GetKeyDown(KeyCode.T)) tileHeightMap();

        /*
        if (Input.GetMouseButtonDown(0))
        {
            Vector3 mouseWorldPosition = Camera.main.ScreenToWorldPoint(Input.mousePosition);

            Vector3 mouse = new Vector3(Mathf.Floor(mouseWorldPosition.x) + (sample / 2), Mathf.Floor(mouseWorldPosition.y) + (sample / 2), 0);

            //TileMap.SetTile(new Vector3Int(Mathf.RoundToInt(mouse.x - (sample / 2)), Mathf.RoundToInt(mouse.y - (sample / 2)), 0), null);

            Debug.Log(Map[Mathf.RoundToInt(mouse.x), Mathf.RoundToInt(mouse.y)]);
        }
        */
    }

    public void Reset()
    {
        genHeightMap();

        tileHeightMap();
    }
}
