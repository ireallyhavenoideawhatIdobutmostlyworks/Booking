// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Booking {

    enum Country {   
        POLAND, 
        GERMANY,
        ITALY
    }

    struct Hotel {
        uint id;
        string name;
        string city;
        Country country;
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
        address tenant;
        uint price;
        uint totalNumberOfDaysOfRoomRental;
        uint startDate;
        uint endDate;
    }


    address taxOffice;

    Reservation[] private reservation;
    uint private reservationID;
   

    constructor(address _taxOffice) {
        reservationID = 0; 
        taxOffice = _taxOffice;
    }

    function createReservation(uint _roomID, uint _hotelID, uint _totalNumberOfDaysOfRoomRental) payable public {
        require(_roomID > 0 && _roomID <= prepareHotelRooms().length, "Invalid room ID");
        require(_hotelID > 0 && _hotelID <= prepareHotels().length, "Invalid hotel ID");
        require(_totalNumberOfDaysOfRoomRental > 0, "Total number of days of room rental should be greater than 0");

        Room memory selectedRoom = prepareHotelRooms()[_roomID - 1];
        Hotel memory selectedHotel = prepareHotels()[_hotelID - 1];

        uint totalCostOfRentingRoom = calculatePrice(_totalNumberOfDaysOfRoomRental, selectedRoom.ratePerDay);
        incrementReservationID();

        Reservation memory newReservation = Reservation(reservationID, selectedHotel, selectedRoom, msg.sender, totalCostOfRentingRoom, _totalNumberOfDaysOfRoomRental, block.timestamp, block.timestamp + _totalNumberOfDaysOfRoomRental);
        reservation.push(newReservation);
    }

    function getReservations() public view returns (Reservation[] memory) {
        return reservation;
    }

    function getTaxes() public view onlyTaxOffice returns (uint taxex) {
        uint income = calculateTotalIncome();
        return (income * 23) / 100;
    }



    function prepareHotelRooms() private pure returns (Room[] memory) {
        Room[] memory hotelRooms = new Room[](6);
        hotelRooms[0] = Room(1, "Premium 1", 200, 1, 4, true, true, true);
        hotelRooms[1] = Room(2, "Premium 2", 200, 1, 4, true, true, false);
        hotelRooms[2] = Room(3, "Standard 1", 100, 1, 6, true, false, true);
        hotelRooms[3] = Room(4, "Standard 2", 200, 1, 7, false, false, false);
        hotelRooms[4] = Room(5, "Poor 1", 50, 1, 10, false, false, true);
        hotelRooms[5] = Room(6, "Poor 2", 50, 1, 20, false, false, false);
        return hotelRooms;
    }

    function prepareHotels() private pure returns (Hotel[] memory) {
        Hotel[] memory hotels = new Hotel[](3);
        hotels[0] = Hotel(1, "Hotel Premium", "Premium", Country.POLAND, "Glogowska", "61-500", "500-500-505", 5, true);
        hotels[1] = Hotel(2, "Hotel Standard", "Standard", Country.POLAND, "Glogowska", "61-300", "300-300-300", 3, true);
        hotels[2] = Hotel(3, "Hotel Poor", "Poor", Country.POLAND, "Glogowska", "61-100", "100-100-100", 1, true);
        return hotels;
    }

    function calculatePrice(uint _days, uint _ratePerDay) private pure returns (uint price) {
        return _days * _ratePerDay;
    }

    function incrementReservationID() private {
        reservationID++;
    }

    function calculateTotalIncome() private view returns (uint) {
        uint sum = 0;
        for (uint i = 0; i < reservation.length; i++) {
            sum += reservation[i].price;
        }
        return sum;
    }


     modifier onlyTaxOffice() {
        require(msg.sender == taxOffice, "Only tax office can call this function");
        _;
    }

} 