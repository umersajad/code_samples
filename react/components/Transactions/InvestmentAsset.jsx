import { Box, styled } from "@mui/material";
import PropTypes from "prop-types";

const InvestmentOfferings = styled(Box)(() => ({
  width: "auto",
  border: "0.0625rem soild",
  fontFamily: "THICCCBOI-SemiBold",
  color: "#564e4a",
}));

const InvestmentOfferingsContainer = styled(Box)({
  display: "flex",
  gap: "0.375rem",
});

const InvestmentOfferingsTitle = styled(Box)({
  fontFamily: "THICCCBOI-Bold",
  fontSize: "0.875rem",
});

const InvestmentOfferingsAddress = styled(Box)({
  fontFamily: "THICCCBOI-REGULAR",
  fontWeight: "normal",
  fontSize: "0.625rem;",
});

//Todo replace test with BE response
export const InvestmentAsset = ({ asset }) => {
  return (
    <InvestmentOfferings>
      <InvestmentOfferingsContainer>
        <Box>
          <InvestmentOfferingsTitle>{asset?.name}</InvestmentOfferingsTitle>
          <InvestmentOfferingsAddress>{asset?.address?.city + ", " + asset?.address?.state}</InvestmentOfferingsAddress>
        </Box>
      </InvestmentOfferingsContainer>
    </InvestmentOfferings>
  );
};

InvestmentAsset.propsTypes = {
  asset: PropTypes.object,
};

InvestmentAsset.defaultProps = {
  asset: {},
};
