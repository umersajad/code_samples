import { Box, styled } from "@mui/material";
import PrimaryButton from "components/Button/PrimaryButton";
import { urlHandler } from "helpers/routesHelper";
import { FormattedMessage } from "react-intl";
import transactionImage from "assets/images/downloadTransaction.png";
import PropTypes from "prop-types";

function viewTransactionHandler(txHash) {
  if (txHash) {
    urlHandler(`${process.env.REACT_APP_BLOCK_EXPORER_URL}/tx/${txHash}`);
  }
}

const InvestmentOfferingsDownloadImage = styled(Box)(({ allow }) => ({
  width: "2.5rem",
  height: "2.5625rem",
  cursor: allow ? "pointer" : false,
  opacity: allow ? "1" : "0.5",
}));

export const ViewTransaction = ({ isDesktop, web3TxHash }) => {
  return isDesktop ? (
    <PrimaryButton
      onClick={() => viewTransactionHandler(web3TxHash)}
      float="right"
      marginRight="1.25rem"
      backgroundColor="white"
      color="#433BCE"
      width="9.375rem"
      disabled={!web3TxHash}
    >
      <FormattedMessage id="transactions.viewTransaction" />
    </PrimaryButton>
  ) : (
    <InvestmentOfferingsDownloadImage
      onClick={() => viewTransactionHandler(web3TxHash)}
      component="img"
      allow={web3TxHash}
      src={transactionImage}
      alt=""
    />
  );
};

ViewTransaction.propsTypes = {
  asset: PropTypes.bool,
};

ViewTransaction.defaultProps = {
  asset: true,
};
