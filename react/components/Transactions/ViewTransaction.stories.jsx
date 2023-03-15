import { IntlProvider } from "locales";
import { ViewTransaction } from "./ViewTransaction";

export default {
  component: ViewTransaction,
};

const Template = (args) => {
  return (
    <IntlProvider locale={"en"}>
      <ViewTransaction {...args} />
    </IntlProvider>
  );
};

export const Default = Template.bind({});
Default.args = {
  isDesktop: true,
  web3TxHash: "https://mumbai.polygonscan.com/tx/0x8149147c1b3602fa8f5b223cf2e51883cb9c6c0f9b8675a4811ea17cdff82ad2",
};
