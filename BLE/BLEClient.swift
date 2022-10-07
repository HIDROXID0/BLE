//
//  BLEClient.swift
//  BLE
//
//  Created by Alexandre Souto on 04/10/22.
//

import UIKit
import CoreBluetooth


extension CBUUID
{
    static let SERVICE_UUID =  CBUUID(nsuuid: UUID(uuidString: "0716bf69-27fa-44bd-b636-4ab49725c6b0")!)
    static let PACOTE_UUID  =  CBUUID(nsuuid: UUID(uuidString: "0716bf69-27fa-44bd-b636-4ab49725c6b1")!)
    static let RX_UUID      =  CBUUID(nsuuid: UUID(uuidString: "4ac8a682-9736-4e5d-932b-e9b31405049c")!)
}

class BLEClient: NSObject
{
    
    
    private var manager: CBCentralManager!
    
    private var targetPeripheral: CBPeripheral?
    
    private var characteristic: CBCharacteristic?
    
    private var characteristic2: CBCharacteristic?
    
    
    var data = Data()
    
    override init()
    {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
}


    
extension BLEClient: CBCentralManagerDelegate, CBPeripheralDelegate
{
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        if central.state == .poweredOn
        {
            print("Central Ligada")
            central.scanForPeripherals(withServices: [.SERVICE_UUID], options: nil)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        targetPeripheral = peripheral
        peripheral.delegate = self
        central.connect(peripheral,options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        print("Conectado")
        peripheral.discoverServices([.SERVICE_UUID])
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error
        {
            print("Falha ao Descobrir Serviços: \(error)")
            return
        }
        if let service = peripheral.services?.first
        {
            print("Serviços Descobertos")
            peripheral.discoverCharacteristics([.RX_UUID,.PACOTE_UUID], for: service)
            //peripheral.discoverCharacteristics([.RX_UUID], for: service)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error? )
    {
        
        if let error = error
        {
            print("Falha ao descobrir caracteristicas: \(error)")
            return
        }
        
        print("Tudo Pronto")

        guard let characteristicas = service.characteristics else { return }
            characteristic = characteristicas[1]
        
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
                
                if characteristic.properties.contains(.notify) {
                    
                    peripheral.setNotifyValue(true, for: characteristic)
                }

            }
        }
        
    }
    


    func sendText(text: String)
    {
        if (targetPeripheral != nil && characteristic != nil) {
            let data = text.data(using: .utf8)
            targetPeripheral!.writeValue(data!,  for: characteristic!, type: CBCharacteristicWriteType.withResponse)
            print("Dado enviado")
        }
        
    }

 
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
       // print("passou aqui")
        if let characteristicData = characteristic.value, let stringFromData = String(data: characteristicData, encoding: .utf8)
        {
            print(stringFromData)
        }
    }
    
}


