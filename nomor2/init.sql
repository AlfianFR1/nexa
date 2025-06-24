-- Pilih database
USE gmedia_democase;

-- Buat tabel jika belum ada
CREATE TABLE IF NOT EXISTS karyawan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nip VARCHAR(20) NOT NULL UNIQUE,
    nama VARCHAR(100),
    alamat TEXT,
    gender CHAR(1),
    tanggal_lahir DATE
);

CREATE TABLE IF NOT EXISTS log_trx_api (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nip VARCHAR(20),
    keterangan TEXT,
    status TINYINT(1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Buat Stored Procedure
DELIMITER $$

CREATE PROCEDURE sp_add_kary_alfian (
    IN in_nip VARCHAR(20),
    IN in_nama VARCHAR(100),
    IN in_alamat TEXT,
    IN in_gender CHAR(1),
    IN in_tgl_lahir DATE
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO log_trx_api(nip, keterangan, status) VALUES (in_nip, 'Insert gagal karena error SQL', 0);
    END;

    START TRANSACTION;

    IF EXISTS (SELECT 1 FROM karyawan WHERE nip = in_nip) THEN
        INSERT INTO log_trx_api(nip, keterangan, status) VALUES (in_nip, 'Insert gagal karena NIP sudah ada', 0);
        ROLLBACK;
    ELSE
        INSERT INTO karyawan (nip, nama, alamat, gender, tanggal_lahir)
        VALUES (in_nip, in_nama, in_alamat, in_gender, in_tgl_lahir);

        INSERT INTO log_trx_api(nip, keterangan, status) VALUES (in_nip, 'Insert berhasil', 1);

        COMMIT;
    END IF;
END$$

DELIMITER ;

-- Buat View
CREATE OR REPLACE VIEW karyawan_alfian AS
SELECT
    ROW_NUMBER() OVER (ORDER BY id) AS No,
    nip,
    nama,
    alamat,
    CASE
        WHEN gender = 'L' THEN 'Laki - Laki'
        WHEN gender = 'P' THEN 'Perempuan'
        ELSE 'Tidak Diketahui'
    END AS Gend,
    DATE_FORMAT(tanggal_lahir, '%d %M %Y') AS `Tanggal Lahir`
FROM
    karyawan;
