const int valvePin = 9;
int state = LOW;
int val;

void setup() {
  pinMode(valvePin, OUTPUT);
  digitalWrite(valvePin, state);

  Serial.begin(9600);
  Serial.println("STARTING");
  Serial.flush();

}

void loop() {
  Serial.println(val);
  if (Serial.available() > 0) {
    val = Serial.read();
  }
//  if (Serial.available()>0) {
//    int val = Serial.parseInt();
//    Serial.read();
//    if (val == 1) {
//      state = !state;
//    }
//    digitalWrite(valvePin, state);
//  }
}
