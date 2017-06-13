const int lickPin   = 7;      // the number of the pushbutton pin
const int valvePin  = 9;      // the number of the LED pin

int valveState = LOW;         // the current state of the output pin
int lickState;             // the current reading from the input pin
int lastlickState = LOW;   // the previous reading from the input pin
unsigned long lickStamp;
long lastReward;

// the following variables are long's because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long lastDebounceTime = 0;  // the last time the output pin was toggled
float debounceDelay = 20000;    // the debounce time; increase if the output flickers

// float variables from MATLAB (sent each session)
float rewardDur;
float holdTime;

void setup() {
  pinMode(lickPin, INPUT);
  pinMode(valvePin, OUTPUT);

  // set initial LED state
  digitalWrite(valvePin, valveState);

  Serial.begin(9600);
  Serial.println("STARTING...");
  Serial.read();

// retrieve parameters from matlab
  int done = 0;
  int cnt = 0;
  float val[3];
  while (!done) {
    while (Serial.available() > 0) {
      val[cnt] = Serial.parseFloat();
      cnt++;
      if (cnt > 2) {
        done = 1;
        holdTime = val[0];
        rewardDur = val[1];
        debounceDelay = val[2];

        Serial.print("HOLDTIME ");
        Serial.println(val[0]);
        Serial.print("REWARD ");
        Serial.println(val[1]);
        Serial.print("DEBOUNCE ");
        Serial.println(val[2]);
        break;
      }
    }
  }
}

void loop() {
  // read the state of the switch into a local variable:
  int reading = digitalRead(lickPin);

  // check to see if you just pressed the button
  // (i.e. the input went from LOW to HIGH),  and you've waited
  // long enough since the last press to ignore any noise:

  // If the switch changed, due to noise or pressing

  if ((micros() - lastReward) > (long)(rewardDur * (float)1000000)) {
    digitalWrite(valvePin, LOW);
  }

  if (reading != lastlickState) {
    // reset the debouncing timer
    lastDebounceTime = micros();
    lickStamp = lastDebounceTime;
  }

  if ((micros() - lastDebounceTime) > (long)debounceDelay && reading != lickState) {

    lickState = reading;
    //lickStamp = micros();
    //Serial.println(lickStamp);

    if (lickState == HIGH) {
      Serial.print("0  ");
      Serial.println(lickStamp);

      if ((micros() - lastReward) > (long)(holdTime * (float)1000000)) {
        digitalWrite(valvePin, HIGH);
        lastReward = micros();
        Serial.print("1  ");
        Serial.println(micros());
      }
    }
  }

  // save the reading. Next time through the loop,
  // it'll be the lastlickState:
  lastlickState = reading;
}

