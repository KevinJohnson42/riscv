package bit_width is
function bitwidth(max : positive) return positive;
end package;
package body bit_width is
    function bitwidth(max : positive) return positive is
    variable po2 : positive     := 2;
    variable len : positive     := 1;
    begin
        if max = 1 then return 1; end if;
        while max > po2 loop
            po2 := po2 * 2;
            len := len + 1;
        end loop;
        return len;
    end function;
end package body;