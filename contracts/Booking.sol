// SPDX-License-Identifier: GPL-3.0
import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.0;

contract Booking {

    struct Hotel {
        uint id;
        address payable hotelOwner;
        string name;
        string city;
        string street;
        string postalCode;
        string phoneNumber;
        uint rating;
        bool isOpen;
    }

    struct Room {
        uint id;
        string name;
        uint ratePerDay;
        uint minimumPersonAmount;
        uint maximumPersonAmount;
        bool hasWifi;
        bool hasAirConditioning;
        bool isAvailable;
    }

    struct Reservation {
        uint id;
        Hotel hotel;
        Room room;
        address customer;
        uint price;
        uint totalNumberOfDaysOfRoomRental;
        uint startDate;
        uint endDate;
    }

    address payable public customer;

    Reservation[] private reservation;
    uint private reservationID;

    event CalculatePriceLog(uint price);


    constructor(address payable _customer) payable {
        reservationID = 0;
        customer = _customer;
    }

    function createReservation(uint _hotelID, uint _roomID, uint _totalNumberOfDaysOfRoomRental) payable onlyCustomer public {
        require(checkHotelID(_hotelID), "Invalid hotel ID");
        require(checkRoomID(_roomID), "Invalid room ID");
        require(_totalNumberOfDaysOfRoomRental > 0, "Total number of days of room rental should be greater than 0");

        Hotel memory selectedHotel = prepareHotels()[_hotelID - 1];
        Room memory selectedRoom = prepareHotelRooms()[_roomID - 1];
        require(customer.balance > selectedRoom.ratePerDay, string(abi.encodePacked("Customer should have more than ", selectedRoom.ratePerDay, " ETH")));

        uint totalCostOfRentingRoom = calculatePrice(_totalNumberOfDaysOfRoomRental, selectedRoom.ratePerDay);
        require(msg.value >= totalCostOfRentingRoom, string(abi.encodePacked("You are too poor. You sent ", Strings.toString(msg.value), " Wei but cost of room is ", Strings.toString(totalCostOfRentingRoom), " Wei")));

        incrementReservationID();

        Reservation memory newReservation = Reservation(reservationID, selectedHotel, selectedRoom, customer, totalCostOfRentingRoom, _totalNumberOfDaysOfRoomRental, block.timestamp, block.timestamp + _totalNumberOfDaysOfRoomRental);
        reservation.push(newReservation);

        selectedHotel.hotelOwner.transfer(totalCostOfRentingRoom);
    }

    function getReservations() public view returns (Reservation[] memory) {
        require(reservation.length > 0, "Reservations list is empty");
        return reservation;
    }

    function getReservationsAmount() public view returns (uint reservationAmount) {
        require(reservationID > 0, "There are no reservations");
        return reservationID;
    }

    function getCustomerBalance() public view returns (uint customerBalance) {
        return customer.balance;
    }


    modifier onlyCustomer() {
        require(msg.sender == customer, "Only client can call this function");
        _;
    }

    function prepareHotels() private pure returns (Hotel[] memory) {
        Hotel[] memory hotels = new Hotel[](3);
        hotels[0] = Hotel(1, payable(0xdD870fA1b7C4700F2BD7f44238821C26f7392148), "Hotel Premium", "Premium", "Glogowska", "61-500", "500-500-505", 5, true);
        hotels[1] = Hotel(2, payable(0x583031D1113aD414F02576BD6afaBfb302140225), "Hotel Standard", "Standard", "Glogowska", "61-300", "300-300-300", 3, true);
        hotels[2] = Hotel(3, payable(0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB), "Hotel Poor", "Poor", "Glogowska", "61-100", "100-100-100", 1, true);
        return hotels;
    }

    function prepareHotelRooms() private pure returns (Room[] memory) {
        Room[] memory hotelRooms = new Room[](6);
        hotelRooms[0] = Room(1, "Premium 1", 3, 1, 4, true, true, true);
        hotelRooms[1] = Room(2, "Premium 2", 3, 1, 4, true, true, false);
        hotelRooms[2] = Room(3, "Standard 1", 2, 1, 6, true, false, true);
        hotelRooms[3] = Room(4, "Standard 2", 2, 1, 7, false, false, false);
        hotelRooms[4] = Room(5, "Poor 1", 1, 1, 10, false, false, true);
        hotelRooms[5] = Room(6, "Poor 2", 1, 1, 20, false, false, false);
        return hotelRooms;
    }

    function incrementReservationID() private {
        reservationID++;
    }

    function checkHotelID(uint _hotelID) private pure returns (bool) {
        return (_hotelID > 0) && (_hotelID <= prepareHotels().length);
    }

    function checkRoomID(uint _roomID) private pure returns (bool) {
        return (_roomID > 0) && (_roomID <= prepareHotelRooms().length);
    }

    function calculatePrice(uint _days, uint _ratePerDay) private returns (uint price) {
        uint val = (_days * _ratePerDay) * 10 ** 18;

        emit CalculatePriceLog(val);
        emit CalculatePriceLog(_days * _ratePerDay);

        return val;
    }
} 