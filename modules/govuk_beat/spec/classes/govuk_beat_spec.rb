require_relative '../../../../spec_helper'

describe 'govuk_beat', :type => :class do
  context 'enabled (default)' do
    it { is_expected.to compile }
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('govuk_beat::repo') }
    it { is_expected.to contain_class('filebeat') }
  end

  context 'disabled' do
    let(:params) {{ :enable => false }}
    it { is_expected.not_to contain_class('govuk_beat::repo') }
    it { is_expected.not_to contain_class('filebeat') }
  end

end
