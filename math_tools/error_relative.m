function err_rel = error_relative(Um,Us)
err_rel = (Us-Um)./max(abs(Um));
end
