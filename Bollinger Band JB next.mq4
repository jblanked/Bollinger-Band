//+------------------------------------------------------------------+
//|                                          Bollinger Band JB 1.mq4 |
//|                                                         JBlanked |
//|                                                 www.jblanked.com |
//+------------------------------------------------------------------+
#property copyright "JBlanked"
#property link      "www.jblanked.com"
#property version   "1.00"
#property strict
#property show_inputs

#include <CustomFunctionsFix.mqh>

input int bbPeriod = 20;
input int band1Std = 1;
input int band2Std = 4;
input double riskPerTrade = 0.02;
input int magicNB = 214567;

int orderID;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Comment("The EA just started.");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  Comment("The EA is done for now."); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
    double bbLower1 = iBands(NULL,0,bbPeriod,band1Std,0,PRICE_CLOSE,MODE_LOWER,0);
    double bbUpper1 = iBands(NULL,0,bbPeriod,band1Std,0,PRICE_CLOSE,MODE_UPPER,0);
    double bbMid   = iBands(NULL,0,bbPeriod,band1Std,0,PRICE_CLOSE,0,0);
    
    double bbLower2 = iBands(NULL,0,bbPeriod,band2Std,0,PRICE_CLOSE,MODE_LOWER,0);
    double bbUpper2 = iBands(NULL,0,bbPeriod,band2Std,0,PRICE_CLOSE,MODE_UPPER,0);
    
    if(!CheckIfOpenOrdersByMagicNB(magicNB)) //If no open orderes, try to enter new position
    {
   if(Ask < bbLower1) //buys
   {
      double stopLossPrice = NormalizeDouble(bbLower2,Digits);
      double takeProfitPrice = NormalizeDouble(bbMid,Digits);
      
      double lotSize = OptimalLotSize(riskPerTrade,Ask,stopLossPrice);
      
      orderID = OrderSend(NULL,OP_BUYLIMIT,lotSize,Ask,10,stopLossPrice,takeProfitPrice,"Bollinger Bot");
      
      if(orderID < 0) Print("Didn't trade. Error is" + GetLastError());

      //Send buy order
   }
   else if(Bid > bbUpper1) //sells
   {
      double stopLossPrice = NormalizeDouble(bbUpper2,Digits);
      double takeProfitPrice = NormalizeDouble(bbMid,Digits);
      
      double lotSize = OptimalLotSize(riskPerTrade,Bid,stopLossPrice);
      
      orderID = OrderSend(NULL,OP_SELL,lotSize,Bid,10,stopLossPrice,takeProfitPrice);
	  
      if(orderID < 0) Print("Didn't trade. Error is" + GetLastError());

      //Send Sell order
  }
  
  }
  else //else if you already have a position, update orders if required
  {
  if(OrderSelect(orderID,SELECT_BY_TICKET)==true)
  {
   int orderType = OrderType(); // 0 = Long, 1 = Short
      
      double currentMidline = NormalizeDouble(bbMid,Digits);
      
      double TP = OrderTakeProfit();
      
      if(TP != currentMidline)
      {
      
      bool Ans = OrderModify(orderID,OrderOpenPrice(),OrderStopLoss(),currentMidline,0);
      if(Ans == true)
      {
      Print("Order modified:" + orderID);
      }
      }
  }
  }
 }
//+------------------------------------------------------------------+
