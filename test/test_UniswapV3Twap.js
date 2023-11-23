const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("UniswapV3Twap Contract", () => {
    const FACTORY = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
    const TOKEN0_USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const TOKEN1_WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const WETH_DECIMALS = 18;
    const USDC_DECIMALS = 6;
    const FEE = 3000;

    let WETH_AMOUNT, UNISWAP_V3_TWAP;

    before(async () => {
        let weth_amount = "1";
        WETH_AMOUNT = ethers.utils.parseUnits(weth_amount, WETH_DECIMALS);

        // contract deployment
        const uniswapV3Twap = await ethers.getContractFactory("UniswapV3Twap");
        UNISWAP_V3_TWAP = await uniswapV3Twap.deploy(FACTORY, TOKEN0_USDC, TOKEN1_WETH, FEE);
        await UNISWAP_V3_TWAP.deployed();
    });
    
    it("should deploy UniswapV3Twap contract", async () => {
        expect(UNISWAP_V3_TWAP.address).to.exist;
    });

    it("should get price", async () => {
        const price = await UNISWAP_V3_TWAP.estimateAmountOut(TOKEN1_WETH, WETH_AMOUNT, 10);
        console.log("Price: ", ethers.utils.formatUnits(price, USDC_DECIMALS)); 
    });
});