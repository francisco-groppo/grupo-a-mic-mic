#define ITERA 1000000
void setup() {
  // put your setup code here, to run once:
Serial.begin(9600);

Serial.print("Número de termos da série: ");
Serial.println(ITERA);

}

void loop() {
  // put your main code here, to run repeatedly:
  unsigned long iterations = ITERA, curTime, curTime2;
  float x = 1.0;
  float pi = 1.0; //pi inicia o loop igual ao primeiro termo da série de arctg(1)
  
  curTime = millis(); //tempo antes do início do cálculo de pi
  
  for (unsigned long i = 1; i < iterations; i++){
    
    x*=-1.0; //x = 1.0 se i for par, x = -1.0 se i for ímpar
    pi+= x/(2.0f*(float)i+1.0f); //calcula o i-ésimo termo da série de arctg(1)

  }
  
  pi = 4.0*pi;
  
  curTime2 = millis() - curTime; //tempo decorrido para calcular pi

  // printa os dados no serial
  Serial.print("pi: ");
  Serial.println(pi,10);
  Serial.print("Tempo: ");
  Serial.print(curTime2);
  Serial.println(" ms");
  delay(1000);
}
