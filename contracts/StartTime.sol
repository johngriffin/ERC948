pragma solidity ^ 0.4.0;
import 'BokkyPooBahsDateTimeLibrary.sol';

contract DateTime {
        function getYear(uint timestamp) public pure returns (uint year);
        function getMonth(uint timestamp) public pure returns (uint month);
        function getDay(uint timestamp) public pure returns (uint day);
        function getHour(uint timestamp) public pure returns (uint hour);
}

contract StartTime {
  uint public startTime;
  //globally accessible contract instance of the DateTime Library at our specific address
  address public dateTimeAddr = 0x8Fc065565E3e44aef239F1D06aac009D6A524e82;
  DateTime dateTime = DateTime(dateTimeAddr);
  
  function StartTime() public  {
    startTime = now;
  }
  function getStartYear() view public returns (uint16){
      return dateTime.getYear(startTime);
  }
  function getStartMonth() view public returns (uint16){
      return dateTime.getMonth(startTime);
  }
  function getStartDay() view public returns (uint16){
      return dateTime.getDay(startTime);
  }
  function getStartHour() view public returns (uint16){
      return dateTime.getHour(startTime);
}

}