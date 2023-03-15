import { IntlProvider } from "locales";
import { UserInvestmentsFilters } from "./UserInvestmentsFilters";

export default {
  component: UserInvestmentsFilters,
};

const Template = (args) => {
  return (
    <IntlProvider locale={"en"}>
      <UserInvestmentsFilters {...args} />
    </IntlProvider>
  );
};

export const Default = Template.bind({});
Default.args = {};
