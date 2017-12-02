#include <AVR_FreeRTOS.h>
#include <semphr.h>
#include <avr/io.h>
#include <avr/interrupt.h>

// Declare a mutex Semaphore Handle which we will use to manage the Serial Port.
// It will be used to ensure only only one Task is accessing this resource at any time.
SemaphoreHandle_t xSerialSemaphore;

void FlashLED( void *pvParameters );

void setup() {
    if ( xSerialSemaphore == NULL )
    {
        xSerialSemaphore = xSemaphoreCreateMutex();
        if ( ( xSerialSemaphore ) != NULL )
            xSemaphoreGive( ( xSerialSemaphore ) ); 
    }

    xTaskCreate(
        FlashLED ,
        (const portCHAR *)"FlashLED",  // A name just for humans
        128,  // This stack size can be checked & adjusted by reading the Stack Highwater
        NULL,
        2,  // Priority, with 3 (configMAX_PRIORITIES - 1) being the highest, and 0 being the lowest.
        NULL );
}

void FlashLED( void *pvParameters __attribute__((unused)) )  // This is a Task.
{
    DDRB |= (1<<0);
    PORTB |= (1<<0);
    for (;;)
    {
        PORTB ^= (1<<0);
        if ( xSemaphoreTake( xSerialSemaphore, ( TickType_t ) 5 ) == pdTRUE )
        {
            xSemaphoreGive( xSerialSemaphore );
        }
        vTaskDelay(10);  // one tick delay (15ms) 
    }
}
