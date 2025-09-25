using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [SerializeField] private float speed;
    private Rigidbody2D Prb;
    private Animator PAnim;
    private BoxCollider2D playerColl;
    [SerializeField] private float TrueAcc;
    [SerializeField] private float Fastfallspeed;
    private float Acc;
    [SerializeField] private LayerMask Ground;
    [SerializeField] private float JumpForce;
    private bool isJumping;
    [SerializeField] private float jumptime;
    private float jumpTimeCounter;
    [SerializeField] private float AerialSpeedRed;
    private int doubleJump;
    [SerializeField] private bool inLag;
    [SerializeField] private ParticleSystem FireFlow;
    [SerializeField] private ParticleSystem FullbodyFlame;
    private float InputBuffTimer;
    private string BufferedInput;
    [SerializeField] private float NormalFallSpeed;


    private enum State { idle, running, turning, RisingForwards, RisingBackwards, FallingForwards, FallingBackwards}
    private State state = State.idle;

    void Start()
    {
        Prb = GetComponent<Rigidbody2D>();
        PAnim = GetComponent<Animator>();
        playerColl = GetComponent<BoxCollider2D>();
        doubleJump = 1;
        
    }

    // Update is called once per frame
    void Update()
    {
        

        float Hdirection = Input.GetAxis("Horizontal");

        AttackCheck();

        Movement();

        stateController();

        if (BufferedInput != null)
        {
            expireInput();
        }
    }

    private bool Grounded()
    {
        RaycastHit2D GroundCheck = Physics2D.BoxCast(Prb.position + new Vector2(playerColl.offset.x, playerColl.offset.y), playerColl.size - new Vector2 (0.4f,0),0, Vector2.down, 0.1f, Ground);

        if(GroundCheck == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    private void Movement()
    {
        float Hdirection = Input.GetAxis("Horizontal");
        float Vdirection = Input.GetAxis("Vertical");

        

        if (Grounded() == false)
        {
            Acc = TrueAcc / AerialSpeedRed;
        }
        else
        {
            Acc = TrueAcc;
            doubleJump = 1;
        }

        if (Hdirection < 0 & (inLag == false | Grounded() == false))
        {

            

            if (Prb.velocity.x < 0.1 & Prb.velocity.x > -speed / 4 & Grounded())
            {
                Prb.velocity = new Vector2(-speed, Prb.velocity.y);
            }

            Prb.AddForce(new Vector2(-(-Acc * -Prb.velocity.x + speed * Acc), 0), ForceMode2D.Force);

            if(Grounded()) transform.localScale = new Vector2(-1, 1);

        }

        else if (Hdirection > 0 & (inLag == false | Grounded() == false))
        {
            

            if (Prb.velocity.x > -0.1 & Prb.velocity.x < speed / 4 & Grounded())
            {
                Prb.velocity = new Vector2(speed, Prb.velocity.y);
            }

            Prb.AddForce(new Vector2(-Acc * Prb.velocity.x + speed * Acc, 0), ForceMode2D.Force);
            if (Grounded()) transform.localScale = new Vector2(1, 1);

        }


        if (Hdirection == 0)
        {
            if (Prb.velocity.x > 0.1 | Prb.velocity.x < -0.1)
            {
                Prb.AddForce(new Vector2(-Acc * 3 * Prb.velocity.x, 0), ForceMode2D.Force);
            }

        }

        

        if (Input.GetButtonDown("Jump"))
        {
            if (Grounded() == true)
            {
                Prb.velocity = new Vector2(Prb.velocity.x, JumpForce / 2);
                Debug.Log("Jump");
                isJumping = true;
                jumpTimeCounter = jumptime;
            }
            else if (doubleJump > 0)
            {
                Prb.velocity = new Vector2(Prb.velocity.x, JumpForce * 1.5f);
                doubleJump--;
                Debug.Log("Double Jump");
            }
        }



        if (Input.GetButton("Jump") & isJumping == true)
        {
            if(jumpTimeCounter > 0)
            {
                Prb.velocity = new Vector2(Prb.velocity.x, JumpForce);
                jumpTimeCounter -= Time.deltaTime;
                
            }
            else
            {
                isJumping = false;
            }
        }
        
        if (Input.GetButtonUp("Jump"))
        {
            isJumping = false;
        }

        if (Vdirection < -0.99 & Prb.velocity.y > -Fastfallspeed & Grounded() == false & isJumping == false)
        {
            Prb.velocity = new Vector2(Prb.velocity.x, -Fastfallspeed);
        }
        else if (Prb.velocity.y < -NormalFallSpeed)
        {
            Prb.velocity = new Vector2(Prb.velocity.x, -NormalFallSpeed);
        }

        

    }

    private void stateController()
    {

        float Hdirection = Input.GetAxis("Horizontal");

        if (Grounded() == false)
        {
            if (Prb.velocity.y >= 0)
            {
                if(transform.localScale.x * Prb.velocity.x >= -1)
                {
                    state = State.RisingForwards;
                }
                else 
                {
                    state = State.RisingBackwards;
                }
            }
            else
            {
                if (transform.localScale.x * Prb.velocity.x >= -1)
                {
                    state = State.FallingForwards;
                }
                else
                {
                    state = State.FallingBackwards;
                }
            }
        }
        else
        {
            if (Hdirection > 0 & Prb.velocity.x > 0.1)
            {
                state = State.running;
            }
            else if (Hdirection < 0 & Prb.velocity.x < -0.1)
            {
                state = State.running;
            }
            else if (Hdirection > 0 & Prb.velocity.x < -0.1)
            {
                state = State.turning;
            }
            else if (Hdirection < 0 & Prb.velocity.x > 0.1)
            {
                state = State.turning;
            }
            else
            {
                state = State.idle;
            }
        }

        //Debug.Log(state);

        PAnim.SetInteger("PlayerState", (int)state);

    }

    private void AttackCheck()
    {
        float Hdirection = Input.GetAxis("Horizontal");
        float Vdirection = Input.GetAxis("Vertical");
        float AnLeftAngle = Vector2.SignedAngle(new Vector2(0, 1), new Vector2(Hdirection, Vdirection));

        if(AnLeftAngle < 0)
        {
            AnLeftAngle += 360;
        }

        //Debug.Log(AnLeftAngle);

        if (Input.GetButtonDown("Normal") || BufferedInput == "Normal")
        {
            if (inLag == false) 
            {
                BufferedInput = null;

                if (Grounded())
                {
                    if (Mathf.Sqrt(Hdirection * Hdirection + Vdirection * Vdirection) <= 0.4)
                    {
                        PAnim.SetTrigger("Jab");
                    }
                    else if (AnLeftAngle >= 45 & AnLeftAngle <= 135)
                    {
                        Debug.Log("FtiltLeft");
                        PAnim.SetTrigger("Ftilt");
                        transform.localScale = new Vector2(-1, 1);

                    }
                    else if (AnLeftAngle >= 135 & AnLeftAngle <= 225)
                    {
                        Debug.Log("DownTilt");
                        PAnim.SetTrigger("Dtilt");
                    }
                    else if (AnLeftAngle >= 225 & AnLeftAngle <= 315)
                    {
                        Debug.Log("FtiltRight");
                        PAnim.SetTrigger("Ftilt");
                        transform.localScale = new Vector2(1, 1);
                    }
                    else
                    {
                        Debug.Log("Uptilt");
                        PAnim.SetTrigger("Utilt");
                    }
                }
                else
                {
                    if (Mathf.Sqrt(Hdirection * Hdirection + Vdirection * Vdirection) <= 0.25)
                    {
                        PAnim.SetTrigger("Nair");
                    }
                    else if (AnLeftAngle >= 45 & AnLeftAngle <= 135)
                    {


                        if (Hdirection * transform.localScale.x >= 0)
                        {
                            Debug.Log("Fair");
                            PAnim.SetTrigger("Fair");
                        }
                        else
                        {
                            Debug.Log("Bair");
                            PAnim.SetTrigger("Bair");
                        }


                    }
                    else if (AnLeftAngle >= 135 & AnLeftAngle <= 225)
                    {
                        Debug.Log("Dair");
                        PAnim.SetTrigger("Dair");

                    }
                    else if (AnLeftAngle >= 225 & AnLeftAngle <= 315)
                    {
                        if (Hdirection * transform.localScale.x >= 0)
                        {
                            Debug.Log("Fair");
                            PAnim.SetTrigger("Fair");
                        }
                        else
                        {
                            Debug.Log("Bair");
                            PAnim.SetTrigger("Bair");
                        }

                    }
                    else
                    {
                        Debug.Log("UpAir");
                        PAnim.SetTrigger("Uair");
                    }
                }
            }
            else
            {
                //buffer input
                BufferedInput = "Normal";
                InputBuffTimer = Time.time;
            }
            
        }
    }

    private void ParticleOnOff(int On)
    {
        if (On == 1)
        {
            FireFlow.Play();
        }
        else
        {
            FireFlow.Stop();
        }
    }

    private void ParticleOnOffFullBody(int On)
    {
        if (On == 1)
        {
            FullbodyFlame.Play();
        }
        else
        {
            FullbodyFlame.Stop();
        }
    }

    private void expireInput()
    {
        if(InputBuffTimer < Time.time - 10)
        {
            BufferedInput = null;
        }
    }
}
