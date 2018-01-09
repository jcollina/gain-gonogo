// set pin numbers:
const int audioPin = 5;             // audio monitor pin
const int buttonPin = 7;            // lickport pin
const int valvePin = 9;             // water valve pin

// state variables:
int taskState = 0;                  // state of state machine
int stimState = LOW;                // state of stimulus
int rewardState = LOW;              // state of reward
int timeoutState = LOW;             // state of timeout
int winState = LOW;                 // state of response window
int lickState;                      // state of lickport
int lastLickState = LOW;            // state of last lickport sample
int valveState = LOW;               // state of water valve

// other:
int lickOn = 0;
int lickCnt = 0;
int trialType;
int trialCnt = 1;
int cnt = 0;
char trialStr[6];

// time variables:
unsigned long t;                    // master time variable in us
unsigned long lastDebounceTime = 0; // last debounce time in us
unsigned long debounceDelay = 20000;// debounce period in us
unsigned long lickTime = 0;         // lick timestamp in us
unsigned long respWinEnd;
unsigned long rewardEnd;
unsigned long timeoutEnd;
float holdTime;
float respWin;
float rewardDur;
float timeoutDur;


void setup() {
  pinMode(buttonPin, INPUT);
  pinMode(audioPin, INPUT);
  pinMode(valvePin, OUTPUT);

  // set states for indicator and valve
  digitalWrite(valvePin, valveState);

  // setup serial port
  Serial.begin(9600);
  Serial.read();

  // retrieve parameters from matlab
  int done = 0;
  float val[5];
  while (!done) {
    while (Serial.available() > 0) {
      val[cnt] = Serial.parseFloat();
      cnt++;
      if (cnt > 4) {
        done = 1;
        holdTime = val[0];
        respWin = val[1];
        rewardDur = val[2];
        timeoutDur = val[3];
        debounceDelay = val[4];

        Serial.print("HOLDTIME ");
        Serial.println(val[0]);
        Serial.print("RESPWIN ");
        Serial.println(val[1]);
        Serial.print("REWTIME ");
        Serial.println(val[2]);
        Serial.print("TOTIME ");
        Serial.println(val[3]);
        Serial.print("DEBOUNCE ");
        Serial.println(val[4]);
        break;
      }
    }
  }

  // initialize first trial
  sprintf(trialStr,"%04d ",trialCnt);
  Serial.print(trialStr);
  Serial.print(micros());
  Serial.print(" TRIAL");
  Serial.println(trialCnt);

  // seed random number generator
  randomSeed(analogRead(0));

  // clear out the serial
  Serial.read();
  Serial.read();
}

void loop() {
  checkLick();


  switch (taskState) {

    // GET TRIAL TYPE
    case 0: {
        if (Serial.available() > 0) {
          trialType = Serial.read();
          t = micros();
          Serial.print(trialStr);
          Serial.print(t);
          Serial.print(" TT");
          Serial.println(trialType);
          taskState = 1;
        }
        break;
      }


    // HOLD FOR NO LICKS
    case 1: {
        // start the wait timer
        long t0 = millis();
        while ((millis() - t0) < (long)(holdTime * (float)1000)) {
          checkLick();
          // if there is a lick...
          if (lickState == HIGH) {
            // reset the timer
            t0 = millis();
          }
        }

        // let matlab know that the mouse is ready
        t = micros();
        Serial.print(trialStr);
        Serial.print(t);
        Serial.println(" TON");

        // next state
        taskState = 2;
        break;
      }


    // WAIT FOR AUDIO START
    case 2: {
        // check the soundcard input for trial start
        stimState = digitalRead(audioPin);

        if (stimState == HIGH) {
          t = micros();
          Serial.print(trialStr);
          Serial.print(t);
          Serial.println(" STIMON");
          delay(10); // delay to let signal go down again
          taskState = 3;
        }
        break;
      }


    // WAIT FOR RESPONSE WINDOW
    case 3: {
          if (Serial.available() > 0) {
            Serial.println(Serial.read());
          }
        // check the soundcard input for stim offset
        stimState = digitalRead(audioPin);

        if (stimState == HIGH) {
          t = micros();
          respWinEnd = t + (unsigned long)(respWin * (float)1000000);
          Serial.print(trialStr);
          Serial.print(t);
          Serial.println(" RESPON");
          lickTime = 0;
          winState = LOW;
          taskState = 4;
        }
        break;
      }


    // RESPONSE LOGIC
    case 4: {
        if (lickTime > 0) {
          // if the most recent lick was in the window
          if (lickTime > t & lickTime < respWinEnd) {
            // and it was a signal trial
            if (trialType == 49) {
              // deliver reward
              taskState = 5;
            }
            // and it was a noise trial
            else {
              // timeout
              taskState = 6;
            }
          }
        }
        // otherwise, if there were no licks during the window
        if (micros() > respWinEnd) {
          Serial.print(trialStr);
          Serial.print(respWinEnd);
          Serial.println(" RESPOFF");
          winState = HIGH;
          if (trialType == 49) {
            Serial.print(trialStr);
            Serial.print(micros());
            Serial.println (" MISS");
          }
          else {
            Serial.print(trialStr);
            Serial.print(micros());
            Serial.println(" CORRECTREJECT");
          }
          // go to beginning
          taskState = 7;
        }
        break;
      }


    // REWARD
    case 5: {
        // mark response window end
        if (winState == LOW) {
          if (micros() > respWinEnd) {
            Serial.print(trialStr);
            Serial.print(respWinEnd);
            Serial.println(" RESPOFF");
            winState = HIGH;
          }
        }
        // set reward pin to high
        if (rewardState == LOW) {
          // turn on pin and timer
          digitalWrite(valvePin, HIGH);
          t = micros();
          Serial.print(trialStr);
          Serial.print(t);
          Serial.println(" REWARDON");
          rewardEnd = t + (unsigned long)(rewardDur * (float)1000000);
          rewardState = HIGH;
        }
        // when time runs out, turn it off
        if (micros() > rewardEnd) {
          digitalWrite(valvePin, LOW);
          Serial.print(trialStr);
          Serial.print(micros());
          Serial.println(" REWARDOFF");
          rewardState = LOW;
          taskState = 7;
        }
        break;
      }

    // TIMEOUT
    case 6: {
        // mark response window end
        if (winState == LOW) {
          if (micros() > respWinEnd) {
            Serial.print(trialStr);
            Serial.print(respWinEnd);
            Serial.println(" RESPOFF");
            winState = HIGH;
          }
        }
        // initialize timeout
        if (timeoutState == LOW) {
          t = micros();
          timeoutEnd = t + (unsigned long)(timeoutDur * (float)1000000);
          Serial.print(trialStr);
          Serial.print(t);
          Serial.println(" TOSTART");
          timeoutState = HIGH;
        }
        // during timeout
        if (timeoutState == HIGH) {
          // if there is a lick
          if (lickTime > t) {
            // reset the timeout
            t = micros();
            timeoutEnd = t + (unsigned long)(timeoutDur * (float)1000000);
            Serial.print(trialStr);
            Serial.print(t);
            Serial.println(" TOSTART");
          }
          // if the timer expires
          if (micros() >= timeoutEnd) {
            // switch states
            Serial.print(trialStr);
            Serial.print(micros());
            Serial.println(" TOEND");
            taskState = 7;
          }
        }
        break;
      }


    // TRIAL END
    case 7: {
        // Wait for response window to end
        if (winState == LOW) {
          if (micros() > respWinEnd) {
            Serial.print(trialStr);
            Serial.print(respWinEnd);
            Serial.println(" RESPOFF");
            winState = HIGH;
          }
        }
        if (winState == HIGH) {
          // Mark trial end
          Serial.print(trialStr);
          Serial.print(micros());
          Serial.println(" TOFF");
          trialCnt++;
          sprintf(trialStr,"%04d ",trialCnt);
          Serial.print(trialStr);
          Serial.print(micros());
          Serial.print(" TRIAL");
          Serial.println(trialCnt);

          //          // Set random ITI
          //          long randNumber = random(0, 500);
          //          long ITI = randNumber + 2000;
          //          delay(ITI);

          // flush the newline from matlab input for previous trial
          if (Serial.available() > 0) {
            Serial.read();
          }
          taskState = 0;
        }
        break;
      }
  }
}

















void checkLick() {
  // read the state of the switch into a local variable:
  int reading = digitalRead(buttonPin);

  // check to see if you just pressed the button
  // (i.e. the input went from LOW to HIGH),  and you've waited
  // long enough since the last press to ignore any noise:

  // If the switch changed, due to noise or pressing:
  if (reading != lastLickState) {
    // reset the debouncing timer
    lastDebounceTime = micros();
  }

  if ((micros() - lastDebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer
    // than the debounce delay, so take it as the actual current state:

    // if the button state has changed:
    if (reading != lickState) {
      lickState = reading;

      // get timestamp for lick start
      if (lickState == HIGH) {
        lickTime = lastDebounceTime;
        sprintf(trialStr,"%04d ",trialCnt);
        Serial.print(trialStr);
        Serial.print(lickTime);
        Serial.println(" LICK");
      }
    }
  }

  // save the reading.  Next time through the loop,
  // it'll be the lastLickState:
  lastLickState = reading;
}

