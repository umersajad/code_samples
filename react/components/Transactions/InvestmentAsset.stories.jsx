import { IntlProvider } from "locales";
import { InvestmentAsset } from "./InvestmentAsset";

export default {
  component: InvestmentAsset,
};

const Template = (args) => {
  return (
    <IntlProvider locale={"en"}>
      <InvestmentAsset {...args} />
    </IntlProvider>
  );
};

export const Default = Template.bind({});
Default.args = {
  asset: {
    images: [
      {
        url: "https://hb-devcore-public.s3.us-west-2.amazonaws.com/asset/43ff274b-5a90-4d6e-b941-3b851b9e1899/image-gallery/highlight1_labuild_main.png",
      },
    ],
    name: "name",
    address: {
      city: "test city",
      state: "test country",
    },
  },
};
