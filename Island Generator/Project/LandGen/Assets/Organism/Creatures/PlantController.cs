using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Tilemaps;

public class PlantController : MonoBehaviour
{
    [SerializeField] private float maxRange;
    [SerializeField] private float p;
    [SerializeField] private LayerMask collidesWith;
    [SerializeField] private float waterNeeded;
    [SerializeField] private GameObject seed;
    [SerializeField] private float growthTime;

    private Tilemap Ground;
    private Tilemap River;

    // Start is called before the first frame update
    void Start()
    {
        Ground = GameObject.FindGameObjectWithTag("Map").GetComponent<Tilemap>();

        River = GameObject.FindGameObjectWithTag("River").GetComponent<Tilemap>();

        StartCoroutine(Grow(growthTime));

        gameObject.GetComponent<Animator>().speed = 1 / growthTime;
    }

    private IEnumerator Spread()
    {
        Vector3 dir = new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f),0);

        dir = dir.normalized * Random.Range(0, maxRange);

        Vector3Int dirInt = new Vector3Int(Mathf.RoundToInt(dir.x), Mathf.RoundToInt(dir.y),0);

        Vector3Int SpawnP = new Vector3Int(Mathf.FloorToInt(transform.position.x), Mathf.FloorToInt(transform.position.y), 0) + dirInt;

        if (WithinBounds(SpawnP))
        {
            if (Ground.GetTile(SpawnP).name == "Tilesetnano_3" & River.GetTile(SpawnP) == null & !occupied(SpawnP) & EnoughWater(SpawnP))
            {
                GameObject child = (GameObject)Instantiate(seed, SpawnP + new Vector3(0.5f, 0.5f, 0), Quaternion.identity);

                child.name = gameObject.name;
            }
        }

        yield return new WaitForSeconds(p);

        StartCoroutine(Spread());

    }

    private IEnumerator Grow(float time)
    {
        yield return new WaitForSeconds(time);

        StartCoroutine(Spread());
    }

    private bool occupied(Vector3Int point)
    {
        bool occupied = Physics2D.OverlapCircle(new Vector2(point.x, point.y), 0.7f, collidesWith);

        return occupied;
    }

    private bool EnoughWater(Vector3Int point)
    {
        return waterNeeded < GameObject.FindGameObjectWithTag("River").GetComponent<riverGenerator>().RainMapOld[point.x + 38, point.y + 38];
    }

    private bool WithinBounds(Vector3Int Spot)
    {
        if (Spot.x > -37 & Spot.y > -37 & Spot.x < 37 & Spot.y < 37) return true;
        else return false;
    }


}
