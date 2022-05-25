const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("Token contract", function () {

    let tokenFactory, token, owner, addr1, addr2, addrs;

    beforeEach(async function () {
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        tokenFactory = await ethers.getContractFactory("Token");
        token = await tokenFactory.deploy();
    });

    describe("Deployment", () => {
        it("Should set the right owner", async () => {
            expect(await token.owner()).to.equal(owner.address);
        });

        it("Should assign the total token supply to the owner", async () => {
            const ownerBalance = await token.balanceOf(owner.address);
            expect(await token.totalSupply()).to.equal(ownerBalance);
        });
    });

    describe("Transactions", () => {
        it("Should transfer tokens between accounts", async () => {
            await token.transfer(addr1.address, 50)
            const addr1Balance = await token.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(50)

            await token.connect(addr1).transfer(addr2.address, 50)
            const addr2Balance = await token.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(50)
        });

        it("Should fail if sender doesn’t have enough tokens", async function () {
            const initialOwnerBalance = await token.balanceOf(owner.address);
            await expect(
                token.connect(addr1).transfer(owner.address, 1)
            ).to.be.revertedWith("Insufficient token balance");
            expect(await token.balanceOf(owner.address)).to.equal(
                initialOwnerBalance
            );
        });

        it("Should update balances after transfers", async function () {
            const initialOwnerBalance = await token.balanceOf(owner.address);

            // Transfer 100 tokens from owner to addr1.
            await token.transfer(addr1.address, 100);

            // Transfer another 50 tokens from owner to addr2.
            await token.transfer(addr2.address, 50);

            // Check balances.
            const finalOwnerBalance = await token.balanceOf(owner.address);
            expect(finalOwnerBalance).to.equal(initialOwnerBalance.sub(150));

            const addr1Balance = await token.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(100);

            const addr2Balance = await token.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(50);
        });
    });
});