const { expect } = require("chai");
const { ethers } = require("hardhat");

require("@nomiclabs/hardhat-waffle");

describe("Booking.sol", function() {

    let contract;
    let customer;
    const amount = ethers.utils.parseEther("100");
    let customerAddress;
    let hotel;

    const hotels = [
      {
        id: 1,
        hotelOwner: payable(0xdD870fA1b7C4700F2BD7f44238821C26f7392148),
        name: "Hotel Premium",
        city: "Premium",
        street: "Glogowska",
        postalCode: "61-500",
        phoneNumber: "500-500-505",
        rating: 5,
        isOpen: true
      },
      {
        id: 2,
        hotelOwner: payable(0x583031D1113aD414F02576BD6afaBfb302140225),
        name: "Hotel Standard",
        city: "Standard",
        street: "Glogowska",
        postalCode: "61-300",
        phoneNumber: "300-300-300",
        rating: 3,
        isOpen: true
      },
      {
        id: 3,
        hotelOwner: payable(0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB),
        name: "Hotel Poor",
        city: "Poor",
        street: "Glogowska",
        postalCode: "61-100",
        phoneNumber: "100-100-100",
        rating: 1,
        isOpen: true
      }
    ];

    beforeEach(async function() {
      [customer] = await ethers.getSigners();
      [customerAddress] = await customer.getAddress();

      const Booking = await ethers.getContractFactory("Booking");
      const booking = await Booking.deploy(customerAddress);
      contract = await booking.deployed();

      hotel = await contract.callStatic.prepareHotels();


      // const rooms = [
      //   {
      //     id: 1,
      //     name: "Premium 1",
      //     ratePerDay: 3,
      //     minimumPersonAmount: 1,
      //     maximumPersonAmount: 4,
      //     hasWifi: true,
      //     hasAirConditioning: true,
      //     isAvailable: true
      //   },
      //   {
      //     id: 2,
      //     name: "Premium 2",
      //     ratePerDay: 3,
      //     minimumPersonAmount: 1,
      //     maximumPersonAmount: 4,
      //     hasWifi: true,
      //     hasAirConditioning: true,
      //     isAvailable: false
      //   },
      //   {
      //     id: 3,
      //     name: "Standard 1",
      //     ratePerDay: 2,
      //     minimumPersonAmount: 1,
      //     maximumPersonAmount: 6,
      //     hasWifi: true,
      //     hasAirConditioning: false,
      //     isAvailable: true
      //   },
      //   {
      //     id: 4,
      //     name: "Standard 2",
      //     ratePerDay: 2,
      //     minimumPersonAmount: 1,
      //     maximumPersonAmount: 7,
      //     hasWifi: false,
      //     hasAirConditioning: false,
      //     isAvailable: false
      //   },
      //   {
      //     id: 5,
      //     name: "Poor 1",
      //     ratePerDay: 1,
      //     minimumPersonAmount: 1,
      //     maximumPersonAmount: 10,
      //     hasWifi: false,
      //     hasAirConditioning: false,
      //     isAvailable: true
      //   },
      //   {
      //     id: 6,
      //     name: "Poor 2",
      //     ratePerDay: 1,
      //     minimumPersonAmount: 1,
      //     maximumPersonAmount: 10,
      //     hasWifi: false,
      //     hasAirConditioning: false,
      //     isAvailable: false
      //   }
      // ];
    });

    it("Should receive ETH in myFunction", async function() {
      const balanceBefore = await customer.getBalance();
      await contract.createReservation({ value: amount });
      const balanceAfter = await customer.getBalance();
      expect(balanceAfter).to.equal(balanceBefore.sub(amount));
    });
  }
);