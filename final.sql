create database final;
use final;

-- tạo bảng độc giả 
create table readers(
	reader_id varchar(10) primary key,
    full_name varchar(100) not null,
    email varchar(100) not null unique,
    phone_number varchar(20) not null unique,
	created_at date
);

-- tạo bảng chi tiết thẻ thành viên 
create table membership_details(
	card_number varchar(10) primary key,
    reader_id varchar(10) unique,
	member_rank enum("Standard", "VIP") not null,
    expiry_date date not null,
    citizen_id varchar(20) not null unique,
    foreign key(reader_id) references readers(reader_id)
);

-- tạo bảng danh mục sách
create table categories(
	category_id varchar(10) primary key,
	category_name varchar(100) not null,
    description varchar(255) not null
);

-- tạo bảng sách
create table books(
	book_id varchar(10) primary key,
    title varchar(100) not null,
    author varchar(100) not null,
    category_id varchar(10),
    price decimal(10,2),
	stock_quantity int,
    
    foreign key(category_id) references categories(category_id),
	check(price > 0),
    check(stock_quantity >= 0)
);

-- tạo bảng hồ sơ mượn trả
create table loan_records(
	loan_id varchar(10) primary key,
    reader_id varchar(10),
    book_id varchar(10),
    borrow_date date not null,
	due_date date not null,
    return_date date,
    
    foreign key(reader_id) references readers(reader_id),
    foreign key(book_id) references books(book_id)
);

-- Viết script INSERT để chèn dữ liệu mẫu vào 5 bảng
insert into readers(reader_id, full_name, email, phone_number, created_at) values
("1", "Nguyen Van A", "anv@gmail.com", "901234567", "2022-01-15"),
("2", "Tran Thi B", "btt@gmail.com", "912345678", "2022-05-20"),
("3", "Le Van C", "cle@yahoo.com", "922334455", "2023-02-10"),
("4", "Pham Minh D", "dpham@hotmail.com", "933445566", "2023-11-05"),
("5", "Hoang Anh E", "ehoang@gmail.com", "944556677", "2024-01-12");

insert into membership_details(card_number, reader_id, member_rank, expiry_date, citizen_id) values
("CARD-001", "1", "Standard", "2025-01-15", "123456789"),
("CARD-002", "2", "VIP", "2025-05-20", "234567890"),
("CARD-003", "3", "Standard", "2024-01-20", "345678901"),
("CARD-004", "4", "VIP", "2025-11-05", "456789012"),
("CARD-005", "5", "Standard", "2026-01-12", "567890123");

insert into categories(category_id, category_name, description) values
("1", "IT", "Sách về công nghệ thông tin và lập trình"),
("2", "Kinh Te", "Sách kinh doanh, tài chính, khởi nghiệp"),
("3", "Van Hoc", "Tiểu thuyết, truyện ngắn, thơ"),
("4", "Ngoai Ngu", "Sách học tiếng Anh, Nhật, Hàn"),
("5", "Lich Su", "Sách nghiên cứu lịch sử, văn hóa");

insert into books(book_id, title, author, category_id, price, stock_quantity) values
("1", "Clean Code", "Robert C. Martin", "1", "450000", "10"),
("2", "Dac Nhan Tam", "Dale Carnegie", "2", "150000", "50"),
("3", "Harry Potter 1", "J.K. Rowling", "3", "250000", "5"),
("4", "IELTS Reading", "Cambridge", "4", "180000", "0"),
("5", "Dai Viet Su Ky", "Le Van Huu", "5", "300000", "20");

insert into loan_records(loan_id, reader_id, book_id, borrow_date, due_date, return_date) values
("101", "1", "1", "2023-11-15", "2023-11-22", "2023-11-20"),
("102", "2", "2", "2023-12-01", "2023-12-08", "2023-12-05"),
("103", "1", "3", "2024-01-10", "2024-01-17", null),
("104", "3", "4", "2023-05-20", "2023-05-27", null),
("105", "4", "1", "2024-01-18", "2024-01-25", null);

/* Gia hạn thêm 7 ngày cho due_date (Ngày dự kiến trả) đối với tất cả các phiếu mượn sách
 thuộc danh mục 'Van Hoc' mà chưa được trả (return_date IS NULL) */ 
update loan_records
set due_date = date_add(due_date, interval 7 day)
where return_date is null;

/* Xóa các hồ sơ mượn trả (Loan_Records) đã hoàn tất trả sách (return_date KHÔNG NULL) và 
có ngày mượn trước tháng 10/2023. */
delete from loan_records
where return_date is not null and borrow_date < "2023-10-01";

/* Viết câu lệnh lấy ra danh sách các cuốn sách (book_id, title, price) thuộc danh mục 'IT' và 
có giá bán lớn hơn 200.000 VNĐ */
select b.book_id, b.title, b.price from books b
join categories c on c.category_id = b.category_id
where c.category_name = "IT" and b.price > 200000;

/* Lấy ra thông tin độc giả (reader_id, full_name, email) đã đăng ký tài khoản
trong năm 2022 và có địa chỉ Email thuộc tên miền '@gmail.com'. */
select reader_id, full_name, email from readers
where year(created_at) = "2022" and email like "%gmail.com";

/* Hiển thị danh sách 5 cuốn sách có giá trị cao nhất, sắp xếp theo thứ tự giảm dần. 
Yêu cầu sử dụng LIMIT và OFFSET để bỏ qua 2 cuốn sách đắt nhất đầu tiên (lấy từ cuốn thứ 3 
đến thứ 7) */
select * from books
order by price desc
limit 5 offset 2;

/* Viết truy vấn để hiển thị các thông tin gồm: Mã phiếu, Tên độc giả, Tên sách, Ngày mượn, 
Ngày trả. Chỉ hiển thị các đơn mượn chưa trả sách */
select 
	lr.loan_id, 
    r.full_name, 
    b.title, 
    lr.borrow_date, 
    lr.return_date 
from loan_records lr
join readers r on r.reader_id = lr.reader_id
join books b on b.book_id = lr.book_id
where lr.return_date is null;

/* Tính tổng số lượng sách đang tồn kho (stock_quantity) của từng danh mục (category_name). 
Chỉ hiển thị những danh mục có tổng tồn kho lớn hơn 10 */
select 
	c.category_id, 
    c.category_name,
    sum(b.stock_quantity) as total_quantity
from categories c
join books b on b.category_id = c.category_id
group by c.category_id
having sum(b.stock_quantity) > 10;

/* Tìm ra thông tin độc giả (full_name) có hạng thẻ là 'VIP' nhưng chưa từng mượn cuốn sách 
nào có giá trị lớn hơn 300.000 VNĐ */
select r.full_name, b.price from readers r
join membership_details m on m.reader_id = r.reader_id
join loan_records lr on lr.reader_id = r.reader_id
join books b on b.book_id = lr.book_id
where m.member_rank = "VIP"
group by r.reader_id, b.price
having max(b.price) < "300000";

/* Tạo một Composite Index đặt tên là idx_loan_dates trên bảng Loan_Records bao gồm 
hai cột: borrow_date và return_date để tăng tốc độ truy vấn lịch sử mượn */
create index idx_loan_dates on loan_records(borrow_date, return_date);

/* Tạo một View tên là vw_overdue_loans hiển thị: Mã phiếu, Tên độc giả, Tên sách, Ngày mượn, 
Ngày dự kiến trả. View này chỉ chứa các bản ghi mà ngày hiện tại (CURDATE) đã vượt quá ngày dự 
kiến trả và sách chưa được trả */
create or replace view vw_overdue_loans as
select 
	lr.loan_id, 
    r.full_name,
    b.title,
    lr.borrow_date,
    lr.due_date
from loan_records lr
join readers r on r.reader_id = lr.reader_id
join books b on b.book_id = lr.book_id
where lr.return_date is null and curdate() > due_date;

select * from vw_overdue_loans;

/* Viết Trigger trg_after_loan_insert. Khi một phiếu mượn mới được thêm vào bảng Loan_Records, 
hãy tự động trừ số lượng tồn kho (stock_quantity) của cuốn sách tương ứng trong bảng Books đi 1 
đơn vị */
delimiter $$
create trigger trg_after_loan_insert
after insert on loan_records
for each row
begin 
	update books
    set stock_quantity = stock_quantity - 1
    where book_id = new.book_id;
end $$
delimiter ;

drop trigger trg_after_loan_insert;

insert into loan_records(loan_id, reader_id, book_id, borrow_date, due_date) values
("106", "5", "1", "2025-01-01", "2025-02-01");

select * from books;
select * from loan_records;

/* Viết Trigger trg_prevent_delete_active_reader. Ngăn chặn việc xóa thông tin độc giả trong
 bảng Readers nếu độc giả đó vẫn còn sách đang mượn (tức là tồn tại bản ghi trong Loan_Records
 mà return_date là NULL) */
delimiter $$
create trigger trg_prevent_delete_active_reader
before delete on readers
for each row
begin
	-- Kiểm tra độc giả bị xóa có sách chưa trả không
    if (
		select count(*) from loan_records
        where reader_id = old.reader_id and return_date is null
    ) > 0 then
		signal sqlstate "45000" set message_text = "Không thể xóa độc giả có sách chưa trả";
	end if;
end $$
delimiter ;

drop trigger trg_prevent_delete_active_reader;

delete from readers
where reader_id = 1;

/* - Viết Procedure sp_check_availability nhận vào Mã sách (p_book_id). Procedure trả về 
thông báo qua tham số OUT p_message:
  - 'Hết hàng' nếu tồn kho = 0.
  - 'Sắp hết' nếu 0 < tồn kho <= 5.
  - 'Còn hàng' nếu tồn kho > 5 */
delimiter $$
create procedure sp_check_availability(
	in p_book_id varchar(10),
    out p_message varchar(100)
)
begin
	declare quantity int;
    -- Lấy ra số lượng tồn kho 
    select stock_quantity into quantity from books
    where book_id = p_book_id;
    -- Kiểm tra 
    if quantity = 0 then
		set p_message = "Hết hàng";
	elseif quantity <= 5 then
		set p_message = "Sắp hết";
	else set p_message = "Còn hàng";
    end if;
end $$
delimiter ;

drop procedure sp_check_availability;
select * from books;
call sp_check_availability("4", @message);
call sp_check_availability("3", @message);
call sp_check_availability("1", @message);
select @message;

/* - Viết Procedure sp_return_book_transaction để xử lý trả sách an toàn với Transaction:
  - Input: p_loan_id.
  - B1: Bắt đầu giao dịch (START TRANSACTION).
  - B2: Kiểm tra xem phiếu mượn này đã được trả chưa. Nếu return_date không NULL, Rollback 
	và báo lỗi "Sách đã trả rồi".
  - B3: Cập nhật ngày trả (return_date) là ngày hiện tại trong bảng Loan_Records.
  - B4: Cộng lại số lượng tồn kho (stock_quantity) lên 1 trong bảng Books (dựa vào book_id lấy 
	từ phiếu mượn).
  - B5: COMMIT nếu thành công. ROLLBACK nếu có lỗi xảy ra */
delimiter $$
create procedure sp_return_book_transaction(p_loan_id varchar(10))
begin
	declare t_book_id varchar(10);
    -- Bắt đầu transaction
    start transaction;
    -- Kiểm tra trạng thái
    if (
		select return_date from loan_records
        where loan_id = p_loan_id
    ) is not null then
		rollback;
        signal sqlstate "45000" set message_text = "Sách đã trả rồi";
    end if;
    -- Cập nhật ngày trả
    update loan_records
    set return_date = curdate()
    where loan_id = p_loan_id;
    -- Lấy book id để cập số số lượng tồn kho 
	select book_id into t_book_id from loan_records
    where loan_id = p_loan_id;
    -- Cập nhật số lượng tồn kho
	update books
    set stock_quantity = stock_quantity + 1
    where book_id = t_book_id;
    -- Commit dữ liệu
    commit;
end $$
delimiter ;

drop procedure sp_return_book_transaction;

select * from books;
select * from loan_records;
call sp_return_book_transaction("101");
call sp_return_book_transaction("106");
call sp_return_book_transaction("104");