//
// Nanode5 - Daten an ThinkSpeak senden
// Datei: tb_nanode5_ethernet_update_thinkspeak.pde
//
// Beschreibung: Daten von DHT11 und Update in ThingSpeak-Anwendung
//
// Board: Nanode5 0112
// Datum 11.07.2011
//
//
// Status: OK


//--------------------------------------------------------
// EtherShield examples: simple client Emoncms
//
//   simple client code layer:
//
// - ethernet_setup(mac,ip,gateway,server,port)
// - ethernet_ready() - check this before sending
//
// - ethernet_setup_dhcp(mac,serverip,port)
// - ethernet_ready_dhcp() - check this before sending
//
// - ethernet_setup_dhcp_dns(mac,domainname,port)
// - ethernet_ready_dhcp_dns() - check this before sending
//
//   Posting data within request body:
// - ethernet_send_post(PSTR(PACHUBEAPIURL),PSTR(PACHUBE_VHOST),PSTR(PACHUBEAPIKEY), PSTR("PUT "),str);
// 
//   Sending data in the URL
// - ethernet_send_url(PSTR(HOST),PSTR(API),str);
//
//   EtherShield library by: Andrew D Lindsay
//   http://blog.thiseldo.co.uk
//
//   Example by Trystan Lea, building on Andrew D Lindsay's examples
//
//   Projects: Nanode.eu and OpenEnergyMonitor.org
//   Licence: GPL GNU v3
//--------------------------------------------------------

#include <EtherShield.h>
#include "DHT.h"

// Nanode 0112
byte mac[6] =     { 0x00,0x04,0xA3,0x03,0xDE,0x69};
byte ip[4] =      {10,0,1,161};

// Gateway
byte gateway[4] = {10,0,1,1};
// IP von Server ThinkSpeak
byte server[4] =  {184, 106, 153, 149};

// Website/Host
#define HOST "api.thingspeak.com"  // Blank "" if on your local network: www.yourdomain.org if not
#define API "/update?key=LL815M112O24DX2L&"

// DHT Pin
#define DHTPIN 5
// DHT Type
#define DHTTYPE DHT11   // DHT 11 
//#define DHTTYPE DHT22   // DHT 22  (AM2302)
//#define DHTTYPE DHT21   // DHT 21 (AM2301)

// DHT Object
DHT dht(DHTPIN, DHTTYPE);

unsigned long lastupdate;

char str[50];
char fstr[10];
int dataReady=0;

    
void setup()
{
  Serial.begin(9600);
  Serial.println("Temp/Humidity/Light to ThinkSpeak");
  // Ethernet
  ethernet_setup(mac,ip,gateway,server,80,8);
  // DHT11
  dht.begin();
}

void loop()
{
  //Data every 1 Minute
  if ((millis()-lastupdate)>60000)
  {
    lastupdate = millis();
    
    float datastr0=0;
    float datastr1=0;
    float datastr2=0;
    
    // Read Sensors
    float h = dht.readHumidity();
    float t = dht.readTemperature();
    float l = analogRead(0);
        
    // Datastring
    // dtostrf - converts a double to a string!
    // strcat  - adds a string to another string
    // strcpy  - copies a string
    
    if (isnan(t) || isnan(h)) {
      Serial.println("Error Reading DHT11");
    }
    else
    {
      // Temp
      datastr0 = t;
      // Humidity
      datastr1 = h;
      // Light
      datastr2 = l;
      Serial.print("Humidity: ");
      Serial.print(h);
      Serial.print(" %\t");
      Serial.print("Temperature: ");
      Serial.print(t);
      Serial.println(" *C");
      Serial.print("Light: ");
      Serial.println(l);
    }
    
    //Data Strings 
    strcpy(str,"field1=");
    // Data 0 - Temp Indoor
     dtostrf(datastr0,0,1,fstr);
    strcat(str,fstr);
    strcat(str,"&");
    
    // Data 2 - Humidity Indoor
    strcat(str,"field2=");
    dtostrf(datastr1,0,1,fstr);
    strcat(str,fstr);
    strcat(str,"&");

    // Data 3 - Light
    strcat(str,"field3=");
    dtostrf(datastr2,0,1,fstr);
    strcat(str,fstr);
    
    // Serial Data Output
    Serial.print("URL:");
    Serial.print(API);
    Serial.println(str);
    
    // Data Ready 
    dataReady = 1;
 
  }
  
  // Send to Internet
  if (ethernet_ready() && dataReady==1)
  {
    ethernet_send_url(PSTR(HOST),PSTR(API),str);
    Serial.println("sent"); dataReady = 0;
  }
}



